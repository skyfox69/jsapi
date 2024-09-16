# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions
      extend Base::Attributes

      ##
      # :attr: defaults
      # The general default values.
      attribute :defaults, { String => Defaults }, keys: Schema::TYPES, default: {}

      ##
      # :attr: openapi_root
      # The OpenAPI::Root.
      attribute :openapi_root, OpenAPI::Root

      attr_reader :callbacks, :operations, :parameters, :request_bodies,
                  :rescue_handlers, :responses, :schemas

      def initialize(owner = nil)
        @owner = owner
        @callbacks = { on_rescue: [] }
        @operations = {}
        @parameters = {}
        @request_bodies = {}
        @rescue_handlers = []
        @responses = {}
        @schemas = {}
        @self_and_included = [self]
      end

      def add_on_rescue(method_or_proc)
        @callbacks[:on_rescue] << method_or_proc
      end

      def add_operation(name = nil, keywords = {})
        name = name.nil? ? default_operation_name : name.to_s
        @operations[name] = Operation.new(name, keywords.reverse_merge(path: default_path))
      end

      def add_parameter(name, keywords = {})
        name = name.to_s
        @parameters[name] = Parameter.new(name, keywords)
      end

      def add_request_body(name, keywords = {})
        @request_bodies[name.to_s] = RequestBody.new(keywords)
      end

      def add_rescue_handler(klass, status: nil)
        @rescue_handlers << RescueHandler.new(klass, status: status)
      end

      def add_response(name, keywords = {})
        name = name.to_s
        @responses[name] = Response.new(keywords)
      end

      def add_schema(name, keywords = {})
        name = name.to_s
        @schemas[name] = Schema.new(keywords)
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

      # Includes +definitions+.
      def include(definitions)
        return if @self_and_included.include?(definitions)

        @self_and_included << definitions
      end

      def inspect # :nodoc:
        "#<#{self.class.name} owner: #{@owner.inspect}, #{
          %i[operations parameters request_bodies responses schemas
             openapi_root rescue_handlers defaults].map do |name|
            "#{name}: #{send(name).inspect}"
          end.join(', ')
        }>"
      end

      # Returns a hash representing the \JSON \Schema document for +name+.
      def json_schema_document(name)
        schema(name)&.to_json_schema&.tap do |hash|
          definitions =
            @self_and_included
            .map(&:schemas)
            .reduce(&:merge)
            .except(name.to_s)
            .transform_values(&:to_json_schema)

          hash[:definitions] = definitions if definitions.any?
        end
      end

      def on_rescue_callbacks
        @self_and_included.flat_map do |definitions|
          definitions.callbacks[:on_rescue]
        end
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

      def operation(name = nil)
        if (name = name.to_s).present?
          definitions = @self_and_included.find { |d| d.operations.key?(name) }
          definitions.operations[name] if definitions
        elsif @operations.one?
          # return the one and only operation
          @operations.values.first
        end
      end

      def parameter(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.parameters.key?(name) }
        definitions.parameters[name] if definitions
      end

      def request_body(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.request_bodies.key?(name) }
        definitions.request_bodies[name] if definitions
      end

      def rescue_handler_for(exception)
        @self_and_included.each do |definitions|
          definitions.rescue_handlers.each do |rescue_handler|
            return rescue_handler if rescue_handler.match?(exception)
          end
        end
        nil
      end

      def response(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.responses.key?(name) }
        definitions.responses[name] if definitions
      end

      def schema(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.schemas.key?(name) }
        definitions.schemas[name] if definitions
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
