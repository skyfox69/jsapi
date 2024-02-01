# frozen_string_literal: true

module Jsapi
  module Model
    class Definitions
      attr_reader :operations, :parameters, :schemas

      def initialize(owner = nil)
        @owner = owner
        @operations = {}
        @parameters = {}
        @schemas = {}
        @openapi_root = nil
        @self_and_included = [self]
      end

      def add_operation(name = nil, **options)
        name = default_operation_name unless name.present?
        name = name.to_s
        raise "operation already defined: '#{name}'" if @operations.key?(name)

        @operations[name] = Operation.new(name, **options)
      end

      def add_parameter(name, **options)
        name = name.to_s
        raise "parameter already defined: '#{name}'" if @parameters.key?(name)

        @parameters[name.to_s] = Parameter.new(name, **options)
      end

      def add_schema(name, **options)
        name = name.to_s
        raise "schema already defined: '#{name}'" if @schemas.key?(name)

        @schemas[name.to_s] = Schema.new(**options)
      end

      def include(*definitions)
        # TODO: prevent circular references
        @self_and_included += definitions
      end

      def openapi_document
        openapi_root.to_openapi.merge(
          paths:
            @self_and_included
              .map(&:operations)
              .reduce(&:merge)
              .values
              .group_by { |operation| operation.path || default_path }
              .transform_values do |operations|
                operations.index_by(&:method).transform_values(&:to_openapi_operation)
              end,
          components: {
            parameters:
              @self_and_included
                .map(&:parameters)
                .reduce(&:merge)
                .transform_values do |parameter|
                  parameter.to_openapi_parameters.first
                end.presence,
            schemas:
              @self_and_included
                .map(&:schemas)
                .reduce(&:merge)
                .transform_values(&:to_openapi_schema).presence
          }.compact
        ).transform_values(&:presence).compact
      end

      def openapi_root
        @openapi_root ||= Generic.new(openapi: '3.0.3')
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

      def schema(name)
        return unless (name = name.to_s).present?

        definitions = @self_and_included.find { |d| d.schemas.key?(name) }
        return definitions.schemas[name] if definitions.present?
      end

      private

      def default_path
        @default_path ||= @owner.to_s.demodulize.delete_suffix('Controller').underscore
      end
      alias default_operation_name default_path
    end
  end
end
