# frozen_string_literal: true

module Jsapi
  module DSL
    class Definitions < Node
      # Includes all of the API definitions from +classes+.
      def include(*classes)
        classes.each { |c| _meta_model.include(c.api_definitions) }
      end

      def openapi(version = nil, &block)
        wrap_error("openapi #{version}") do
          openapi = _meta_model.openapi_root(version)
          Generic.new(openapi).call(&block) if block.present?
        end
      end

      # Defines an API operation.
      #
      #   api_definitions do
      #     operation 'my_operation', method: 'get', path: '/my_path'
      #   end
      def operation(name = nil, **options, &block)
        wrap_error(name.nil? ? '' : "'#{name}'") do
          operation_model = _meta_model.add_operation(name, **options)
          Operation.new(operation_model).call(&block) if block.present?
        end
      end

      # Defines a reusable parameter.
      #
      #   api_definitions do
      #     parameter 'my_parameter', type: 'string'
      #   end
      def parameter(name, **options, &block)
        wrap_error("'#{name}'") do
          parameter_model = _meta_model.add_parameter(name, **options)
          Parameter.new(parameter_model).call(&block) if block.present?
        end
      end

      # Associates one or more excpetion classes with a status code.
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler(klass, status: with)
        end
      end

      # Defines a reusable schema.
      #
      #   api_definitions do
      #     schema 'my_schema', type: 'object'
      #  end
      def schema(name, **options, &block)
        wrap_error("'#{name}'") do
          schema_model = _meta_model.add_schema(name, **options)
          Schema.new(schema_model).call(&block) if block.present?
        end
      end
    end
  end
end
