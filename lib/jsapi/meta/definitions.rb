# frozen_string_literal: true

module Jsapi
  module Meta
    class Definitions
      attr_reader :operations, :parameters, :rescue_handlers, :schemas

      def initialize(owner = nil)
        @owner = owner
        @operations = {}
        @parameters = {}
        @schemas = {}
        @openapi_roots = {}
        @rescue_handlers = []
        @self_and_included = [self]
      end

      def add_operation(name = nil, **options)
        name = default_operation_name unless name.present?
        name = name.to_s
        raise "operation already defined: '#{name}'" if @operations.key?(name)

        @operations[name] = Operation.new(name, **options.reverse_merge(path: default_path))
      end

      def add_parameter(name, **options)
        name = name.to_s
        raise "parameter already defined: '#{name}'" if @parameters.key?(name)

        @parameters[name.to_s] = Parameter.new(name, **options)
      end

      def add_rescue_handler(klass, status: nil)
        @rescue_handlers << RescueHandler.new(klass, status: status)
      end

      def add_schema(name, **options)
        name = name.to_s
        raise "schema already defined: '#{name}'" if @schemas.key?(name)

        @schemas[name.to_s] = Schema.new(**options)
      end

      def include(definitions)
        return if @self_and_included.include?(definitions)

        @self_and_included << definitions
      end

      def openapi_document(version = '2.0')
        openapi_root(version).to_h.tap do |root|
          if version == '2.0'
            root.merge!(
              paths: openapi_paths(version),
              parameters: openapi_parameters(version),
              definitions: openapi_schemas(version)
            )
          else
            root.merge!(
              paths: openapi_paths(version),
              components: {
                parameters: openapi_parameters(version),
                schemas: openapi_schemas(version)
              }.compact.presence
            )
          end
        end.compact
      end

      def openapi_root(version = '2.0')
        @openapi_roots[version] ||=
          case version
          when '2.0'
            Generic.new(swagger: '2.0')
          when '3.0'
            Generic.new(openapi: '3.0.3')
          when '3.1'
            Generic.new(openapi: '3.1.0')
          else
            raise ArgumentError, "unsupported OpenAPI version: #{version}"
          end
      end

      def operation(name = nil)
        if (name = name.to_s).present?
          definitions = @self_and_included.find { |d| d.operations.key?(name) }
          return definitions.operations[name] if definitions.present?
        elsif @operations.one?
          # return the one and only operation
          @operations.values.first
        end
      end

      def parameter(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.parameters.key?(name) }
        definitions.parameters[name] if definitions.present?
      end

      def rescue_handler_for(exception)
        @self_and_included.each do |definitions|
          definitions.rescue_handlers.each do |rescue_handler|
            return rescue_handler if rescue_handler.match?(exception)
          end
        end
        nil
      end

      def schema(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.schemas.key?(name) }
        return definitions.schemas[name] if definitions.present?
      end

      private

      def default_operation_name
        @default_operation_name ||= @owner.to_s.demodulize.delete_suffix('Controller').underscore
      end

      def default_path
        @default_path ||= "/#{default_operation_name}"
      end

      def openapi_parameters(version)
        @self_and_included
          .map(&:parameters).reduce(&:merge)
          .transform_values do |parameter|
          parameter.to_openapi_parameters(version, self).first
        end.presence
      end

      def openapi_paths(version)
        @self_and_included
          .map(&:operations).reduce(&:merge).values
          .group_by { |operation| operation.path || default_path }
          .transform_values do |operations|
          operations.index_by(&:method).transform_values do |operation|
            operation.to_openapi_operation(version, self)
          end
        end.presence
      end

      def openapi_schemas(version)
        @self_and_included
          .map(&:schemas).reduce(&:merge).transform_values do |schema|
          schema.to_openapi_schema(version)
        end.presence
      end
    end
  end
end
