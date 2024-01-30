# frozen_string_literal: true

module Jsapi
  module Model
    class Definitions
      attr_reader :operations, :parameters, :paths, :schemas

      def initialize
        @included = []
        @parameters = {}
        @paths = {}
        @openapi_root = nil
        @operations = {}
        @schemas = {}

        # Cache
        @_operations = nil
        @_parameters = nil
        @_schemas = nil
      end

      def add_parameter(name, **options)
        @_parameters = nil
        @parameters[name.to_s] = Model::Parameter.new(name, **options)
      end

      def add_path(path, path_model)
        @_operations = nil
        @paths[path.to_s] = path_model

        path_model.operations.each_value do |operation|
          @operations[operation.operation_id.to_s] = operation
        end
        path
      end

      def add_schema(name, **options)
        @_schemas = nil
        @schemas[name.to_s] = Model::Schema.new(**options)
      end

      def include(*definitions)
        # TODO: prevent circular references
        @_operations = nil
        @_parameters = nil
        @_schemas = nil

        @included += definitions.reverse
      end

      def openapi_document
        openapi_root.to_openapi.merge(
          paths: _paths.transform_values(&:to_openapi_path),
          components: {
            parameters: _parameters.transform_values do |parameter|
              parameter.to_openapi_parameters.first
            end.presence,
            schemas: _schemas.transform_values(&:to_openapi_schema).presence
          }.compact
        ).transform_values(&:presence).compact
      end

      def openapi_root
        @openapi_root ||= Generic.new(openapi: '3.0.3')
      end

      def operation(operation_id)
        # TODO: raise error if nil?
        _operations[operation_id.to_s]
      end

      def path(name)
        _paths[name.to_s]
      end

      def parameter(name)
        _parameters[name.to_s]
      end

      def schema(name)
        _schemas[name.to_s]
      end

      private

      def _operations
        @_operations ||= @included.map(&:operations).reduce({}, &:reverse_merge).merge(@operations)
      end

      def _parameters
        @_parameters ||= @included.map(&:parameters).reduce({}, &:merge).merge(@parameters)
      end

      def _paths
        @included.map(&:paths).reduce({}, &:merge).merge(@paths)
      end

      def _schemas
        @_schemas ||= @included.map(&:schemas).reduce({}, &:merge).merge(@schemas)
      end
    end
  end
end
