# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify an OpenAPI callback object.
    class Callback < Base

      # Adds a callback operation.
      #
      #   operation '{$request.query.foo}' do
      #     parameter 'bar', type: 'string'
      #   end
      def operation(expression, **keywords, &block)
        define('operation', expression.inspect) do
          operation_model = @meta_model.add_operation(expression, keywords)
          Operation.new(operation_model, &block) if block
        end
      end
    end
  end
end
