# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions < Base::Model
      ##
      # :attr_reader: children
      # The +Definitions+ instances that directly inherit from this instance.
      attribute :children, read_only: true, default: []

      ##
      # :attr: defaults
      # The Defaults.
      attribute :defaults, { String => Defaults }, keys: Schema::TYPES, default: {}

      ##
      # :attr: dependent_definitions
      # The +Definitions+ instances that directly include this instance.
      attribute :dependent_definitions, read_only: true, default: []

      ##
      # :attr: included_definitions
      # The +Definitions+ instances included.
      attribute :included_definitions, [Definitions], add_method: :include, default: []

      ##
      # :attr: on_rescues
      # The methods or procs to be called whenever an exception is rescued.
      attribute :on_rescues, [], default: []

      ##
      # :attr: openapi
      # The OpenAPI root object.
      attribute :openapi, OpenAPI

      ##
      # :attr: operations
      # The Operation objects.
      attribute :operations, { String => Operation }, default: {}

      ##
      # :attr_reader: owner
      # The class to which this instance is assigned.
      attribute :owner, read_only: true

      ##
      # :attr: parameters
      # The reusable Parameter objects.
      attribute :parameters, { String => Parameter }, default: {}

      ##
      # :attr_reader: parent
      # The +Definitions+ instance from which this instance inherits.
      attribute :parent, read_only: true

      ##
      # :attr: rescue_handlers
      # The RescueHandler objects.
      attribute :rescue_handlers, [RescueHandler], default: []

      ##
      # :attr: request_bodies
      # The reusable RequestBody objects.
      attribute :request_bodies, { String => RequestBody }, default: {}

      ##
      # :attr: responses
      # The reusable Response objects.
      attribute :responses, { String => Response }, default: {}

      ##
      # :attr: schemas
      # The reusable Schema objects.
      attribute :schemas, { String => Schema }, default: {}

      undef add_operation, add_parameter, include

      def initialize(keywords = {})
        @owner = keywords.delete(:owner)
        @parent = keywords.delete(:parent)
        super(keywords)

        @parent&.inherited(self)
      end

      def add_operation(name = nil, keywords = {}) # :nodoc:
        name = name.nil? ? default_operation_name : name.to_s
        keywords = keywords.reverse_merge(path: default_path)
        (@operations ||= {})[name] = Operation.new(name, keywords)
      end

      def add_parameter(name, keywords = {}) # :nodoc:
        name = name.to_s
        (@parameters ||= {})[name] = Parameter.new(name, keywords)
      end

      # Returns an array containing itself and all of the +Definitions+ instances
      # inherited/included.
      def ancestors
        @ancestors ||= [self].tap do |ancestors|
          (included_definitions + Array(parent)).each do |included_or_parent|
            included_or_parent.ancestors.each do |definitions|
              ancestors << definitions
            end
          end
        end.uniq
      end

      # Returns the default value for +type+ within +context+.
      def default_value(type, context: nil)
        components.dig(:defaults, type.to_s)&.value(context: context)
      end

      # Returns the operation with the specified name.
      def find_operation(name = nil)
        return components.dig(:operations, name.to_s) if name.present?

        # Return the one and only operation
        operations.values.first if operations.one?
      end

      # Returns the reusable parameter with the specified name.
      def find_parameter(name)
        components.dig(:parameters, name&.to_s)
      end

      # Returns the reusable request body with the specified name.
      def find_request_body(name)
        components.dig(:request_bodies, name&.to_s)
      end

      # Returns the reusable response with the specified name.
      def find_response(name)
        components.dig(:responses, name&.to_s)
      end

      # Returns the reusable schema with the specified name.
      def find_schema(name)
        components.dig(:schemas, name&.to_s)
      end

      # Includes +definitions+.
      def include(definitions)
        if circular_dependency?(definitions)
          raise ArgumentError, 'detected circular dependency between ' \
                               "#{owner.inspect} and " \
                               "#{definitions.owner.inspect}"
        end

        (@included_definitions ||= []) << definitions
        definitions.included(self)
        attribute_changed(:included_definitions)
        self
      end

      def inspect(*attributes) # :nodoc:
        super(*(attributes.presence || %i[owner]))
      end

      # Returns a hash representing the \JSON \Schema document for +name+.
      def json_schema_document(name)
        find_schema(name)&.to_json_schema&.tap do |hash|
          schemas = components[:schemas].except(name.to_s)
          hash[:definitions] = schemas.transform_values(&:to_json_schema) if schemas.any?
        end
      end

      # Returns the methods or procs to be called when rescuing an exception.
      def on_rescue_callbacks
        components[:on_rescues]
      end

      # Returns a hash representing the \OpenAPI document for +version+.
      #
      # Raises an +ArgumentError+ if +version+ is not supported.
      def openapi_document(version = nil)
        version = OpenAPI::Version.from(version)
        operations = components[:operations].values

        components = if version.major == 2
                       {
                         definitions: :schemas,
                         parameters: :parameters,
                         responses: :responses
                       }
                     else
                       {
                         schemas: :schemas,
                         parameters: :parameters,
                         requestBodies: :request_bodies,
                         responses: :responses
                       }
                     end

        openapi_components = ancestors.map do |definitions|
          components.transform_values do |method|
            definitions.send(method).transform_values do |component|
              case method
              when :parameters
                component.to_openapi(version, self).first
              when :responses
                component.to_openapi(version, self)
              else
                component.to_openapi(version)
              end
            end.presence
          end.compact
        end.reduce(&:reverse_merge)

        (openapi&.to_openapi(version, self) || {}).tap do |h|
          h[:paths] = operations
                      .group_by { |operation| operation.path || default_path }
                      .transform_values do |op|
                        op.index_by(&:method).transform_values do |operation|
                          operation.to_openapi(version, self)
                        end
                      end.presence

          if version.major == 2
            consumes = operations.filter_map { |operation| operation.consumes(self) }
            h[:consumes] = consumes.uniq.sort if consumes.present?

            produces = operations.flat_map { |operation| operation.produces(self) }
            h[:produces] = produces.uniq.sort if produces.present?

            h.merge!(openapi_components)
          elsif openapi_components.any?
            (h[:components] ||= {}).merge!(openapi_components)
          end
        end.compact
      end

      # Returns the first RescueHandler to handle +exception+, or nil if no one could be found.
      def rescue_handler_for(exception)
        components[:rescue_handlers].find { |r| r.match?(exception) }
      end

      protected

      def attribute_changed(name) # :nodoc:
        return if name == :openapi

        if name == :included_definitions
          invalidate_ancestors
        else
          invalidate_components
        end
      end

      # Invoked whenever it is included in another +Definitions+ instance.
      def included(definitions)
        (@dependent_definitions ||= []) << definitions
      end

      # rubocop:disable Lint/MissingSuper

      # Invoked whenever it is inherited by another +Definitions+ instance.
      def inherited(definitions)
        (@children ||= []) << definitions
      end

      # rubocop:enable Lint/MissingSuper

      # Invalidates cached ancestors.
      def invalidate_ancestors
        @ancestors = nil
        @components = nil
        (children + dependent_definitions).each(&:invalidate_ancestors)
      end

      # Invalidates cached components.
      def invalidate_components
        @components = nil
        (children + dependent_definitions).each(&:invalidate_components)
      end

      private

      def circular_dependency?(other)
        return true if other == self
        return false if other.included_definitions.none?

        other.included_definitions.any? { |included| circular_dependency?(included) }
      end

      def components
        @components ||= ancestors.each_with_object({}) do |ancestor, components|
          %i[defaults operations parameters request_bodies responses schemas].each do |type|
            (components[type] ||= {}).reverse_merge!(ancestor.send(type))
          end
          %i[on_rescues rescue_handlers].each do |type|
            (components[type] ||= []).push(*ancestor.send(type))
          end
        end
      end

      def default_operation_name
        @default_operation_name ||=
          @owner.to_s.demodulize.delete_suffix('Controller').underscore
      end

      def default_path
        @default_path ||= "/#{default_operation_name}"
      end
    end
  end
end
