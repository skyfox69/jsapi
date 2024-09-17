# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions < Base::Model
      ##
      # :attr: defaults
      # The general default values.
      attribute :defaults, { String => Defaults }, keys: Schema::TYPES, default: {}

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
      attribute :operations, { String => Operation }, default: {}, writer: false

      ##
      # :attr_reader: owner
      attribute :owner, writer: false

      ##
      # :attr: parameters
      # The reusable Parameter objects.
      attribute :parameters, { String => Parameter }, default: {}, writer: false

      ##
      # :attr: rescue_handlers
      # The rescue handlers.
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

      def initialize(owner = nil)
        @owner = owner
        @self_and_included = [self]
        super()
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

      # Returns the default value for +type+ within +context+.
      def default_value(type, context: nil)
        return unless (type = type.to_s).present?

        @self_and_included.each do |definitions|
          default = definitions.default(type)
          return default.value(context: context) if default
        end
        nil
      end

      def find_component(type, name)
        return unless (name = name.to_s).present?

        @self_and_included.each do |definitions|
          component = definitions.send(type, name)
          return component if component.present?
        end
        nil
      end

      def find_operation(name = nil)
        return find_component(:operation, name) if name.present?

        # Return the one and only operation
        operations.values.first if operations.one?
      end

      # Includes +definitions+.
      def include(definitions)
        return if @self_and_included.include?(definitions)

        @self_and_included << definitions
      end

      # Returns a hash representing the \JSON \Schema document for +name+.
      def json_schema_document(name)
        find_component(:schema, name)&.to_json_schema&.tap do |hash|
          definitions = @self_and_included
                        .map(&:schemas)
                        .reduce(&:merge)
                        .except(name.to_s)
                        .transform_values(&:to_json_schema)

          hash[:definitions] = definitions if definitions.any?
        end
      end

      # Returns the methods or procs to be called when rescuing an exception.
      def on_rescue_callbacks
        @self_and_included.flat_map(&:on_rescues)
      end

      # Returns a hash representing the \OpenAPI document for +version+.
      #
      # Raises an +ArgumentError+ if +version+ is not supported.
      def openapi_document(version = nil)
        version = OpenAPI::Version.from(version)

        operations = @self_and_included.map(&:operations).reduce(&:reverse_merge).values

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

        openapi_components = @self_and_included.map do |definitions|
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
        @self_and_included.each do |definitions|
          definitions.rescue_handlers.each do |rescue_handler|
            return rescue_handler if rescue_handler.match?(exception)
          end
        end
        nil
      end

      private

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
