# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      # Used to specify details of a callback.
      class Callback < Node

        # Adds a callback operation.
        #
        #   operation '{$request.query.foo}' do
        #     parameter 'bar', type: 'string'
        #   end
        def operation(expression, **keywords, &block)
          _define('operation', expression.inspect) do
            operation_model = _meta_model.add_operation(expression, keywords)
            Operation.new(operation_model, &block) if block
          end
        end
      end
    end
  end
end
