# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions
      attr_reader :callbacks, :examples, :openapi_root, :operations, :parameters,
                  :request_bodies, :rescue_handlers, :responses, :schemas

      def initialize(owner = nil)
        @callbacks = { on_rescue: [] }
        @owner = owner
        @examples = {}
        @operations = {}
        @parameters = {}
        @request_bodies = {}
        @responses = {}
        @schemas = {}
        @rescue_handlers = []
        @self_and_included = [self]
      end

      def add_example(name, keywords = {})
        @examples[name.to_s] = OpenAPI::Example.new(keywords)
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

      def example(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.examples.key?(name) }
        definitions.examples[name] if definitions
      end

      def include(definitions)
        return if @self_and_included.include?(definitions)

        @self_and_included << definitions
      end

      def inspect # :nodoc:
        "#<#{self.class.name} #{
          %i[owner operations parameters request_bodies responses schemas
             examples openapi_root rescue_handlers].map do |name|
            "#{name}: #{instance_variable_get("@#{name}").inspect}"
          end.join(', ')
        }>"
      end

      # Returns the JSON Schema document for the given schema as a +Hash+.
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

      # Returns a hash representing the OpenAPI document for +version+.
      # Raises an +ArgumentError+ if +version+ is not supported.
      def openapi_document(version = nil)
        version = OpenAPI::Version.from(version)

        (openapi_root&.to_openapi(version, self) || {}).tap do |h|
          h[:paths] = openapi_paths(version)

          if version.major == 2
            h.merge!(
              definitions: openapi_schemas(version),
              parameters: openapi_parameters(version),
              responses: openapi_responses(version)
            )
          else
            h[:components] = (h[:components] || {}).merge(
              schemas: openapi_schemas(version),
              parameters: openapi_parameters(version),
              requestBodies: openapi_request_bodies(version),
              responses: openapi_responses(version),
              examples: openapi_examples
            ).compact.presence
          end
        end.compact
      end

      def openapi_root=(keywords = {})
        @openapi_root = OpenAPI::Root.new(**keywords)
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

      def openapi_examples
        @self_and_included
          .map(&:examples).reduce(&:merge)
          .transform_values(&:to_openapi)
          .presence
      end

      def openapi_parameters(version)
        @self_and_included
          .map(&:parameters).reduce(&:merge)
          .transform_values do |parameter|
          parameter.to_openapi(version, self).first
        end.presence
      end

      def openapi_paths(version)
        @self_and_included
          .map(&:operations).reduce(&:merge).values
          .group_by { |operation| operation.path || default_path }
          .transform_values do |operations|
          operations.index_by(&:method).transform_values do |operation|
            operation.to_openapi(version, self)
          end
        end.presence
      end

      def openapi_request_bodies(version)
        @self_and_included
          .map(&:request_bodies).reduce(&:merge).transform_values do |request_body|
            request_body.to_openapi(version)
          end.presence
      end

      def openapi_responses(version)
        @self_and_included
          .map(&:responses).reduce(&:merge).transform_values do |response|
          response.to_openapi(version, self)
        end.presence
      end

      def openapi_schemas(version)
        @self_and_included
          .map(&:schemas).reduce(&:merge).transform_values do |schema|
          schema.to_openapi(version)
        end.presence
      end
    end
  end
end
