# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions < Base::Model
      ##
      # :attr: defaults
      # The Defaults.
      attribute :defaults, { String => Defaults }, keys: Schema::TYPES, default: {}

      ##
      # :attr: included
      # The Definitions included.
      attribute :included, [Definitions], default: []

      ##
      # :attr: on_rescues
      # The methods or procs to be called when rescuing an exception.
      attribute :on_rescues, [Object], default: []

      ##
      # :attr: openapi_root
      # The OpenAPI::Root object.
      attribute :openapi_root, OpenAPI::Root

      ##
      # :attr: operations
      # The Operation objects.
      attribute :operations, { String => Operation }, default: {}

      ##
      # :attr_reader: owner
      # The class to which it is assigned.
      attribute :owner, Class, writer: false

      ##
      # :attr: parameters
      # The reusable Parameter objects.
      attribute :parameters, { String => Parameter }, default: {}

      ##
      # :attr_reader: parent
      # The Definitions from which it inherits.
      attribute :parent, Definitions, writer: false

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

      def initialize(keywords = {})
        @owner = keywords.delete(:owner)
        @parent = keywords.delete(:parent)

        super(keywords)
      end

      undef add_included, add_operation, add_parameter

      def add_included(definitions) # :nodoc:
        if circular_dependency?(definitions)
          raise ArgumentError, 'detected circular dependency between ' \
                               "#{owner.inspect} and " \
                               "#{definitions.owner.inspect}"
        end

        (@included ||= []) << definitions
        self
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

      # Returns an array containing itself and all of the definitions inherited/included.
      def ancestors
        [self].tap do |ancestors|
          (included + Array(parent)).each do |included_or_parent|
            included_or_parent.ancestors.each do |definitions|
              ancestors << definitions
            end
          end
        end.uniq
      end

      # Returns the default value for +type+ within +context+.
      def default_value(type, context: nil)
        return unless (type = type.to_s).present?

        ancestors.each do |definitions|
          default = definitions.default(type)
          return default.value(context: context) if default
        end
        nil
      end

      # Returns the component with the specified type and name.
      def find_component(type, name)
        return unless (name = name.to_s).present?

        ancestors.each do |definitions|
          component = definitions.send(type, name)
          return component if component.present?
        end
        nil
      end

      # Returns the operation with the specified name.
      def find_operation(name = nil)
        return find_component(:operation, name) if name.present?

        # Return the one and only operation
        operations.values.first if operations.one?
      end

      def inspect(*attributes) # :nodoc:
        super(*(attributes.presence || %i[owner parent included]))
      end

      # Returns a hash representing the \JSON \Schema document for +name+.
      def json_schema_document(name)
        find_component(:schema, name)&.to_json_schema&.tap do |hash|
          definitions = ancestors
                        .map(&:schemas)
                        .reduce(&:merge)
                        .except(name.to_s)
                        .transform_values(&:to_json_schema)

          hash[:definitions] = definitions if definitions.any?
        end
      end

      # Returns the methods or procs to be called when rescuing an exception.
      def on_rescue_callbacks
        ancestors.flat_map(&:on_rescues)
      end

      # Returns a hash representing the \OpenAPI document for +version+.
      #
      # Raises an +ArgumentError+ if +version+ is not supported.
      def openapi_document(version = nil)
        version = OpenAPI::Version.from(version)

        operations = ancestors.map(&:operations).reduce(&:reverse_merge).values

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

        (openapi_root&.to_openapi(version, self) || {}).tap do |h|
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
        ancestors.each do |definitions|
          definitions.rescue_handlers.each do |rescue_handler|
            return rescue_handler if rescue_handler.match?(exception)
          end
        end
        nil
      end

      private

      def circular_dependency?(other)
        return true if other == self
        return false if other.included.none?

        other.included.any? { |included| circular_dependency?(included) }
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
