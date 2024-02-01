# frozen_string_literal: true

module Jsapi
  module DSL
    class Definitions < Node
      %i[info security server].each do |name|
        define_method(name) do |**keywords, &block|
          generic_model = model.openapi_root.add_child(name, **keywords)
          Generic.new(generic_model).call(&block) if block.present?
        end
      end

      # Includes all of the API definitions from +classes+.
      def include(*classes)
        model.include(*classes.map(&:api_definitions))
      end

      # Defines an API operation.
      #
      #   api_definitions do
      #     operation 'my_operation', method: 'get', path: '/my_path'
      #   end
      def operation(name, **options, &block)
        wrap_error("'#{name}'") do
          operation_model = model.add_operation(name, **options)
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
          parameter_model = model.add_parameter(name, **options)
          Parameter.new(parameter_model).call(&block) if block.present?
        end
      end

      # Defines a reusable schema.
      #
      #   api_definitions do
      #     schema 'my_schema', type: 'object'
      #  end
      def schema(name, **options, &block)
        wrap_error("'#{name}'") do
          schema_model = model.add_schema(name, **options)
          Schema.new(schema_model).call(&block) if block.present?
        end
      end
    end
  end
end
