# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        class ModelTest < Minitest::Test
          def test_operations
            expression = '{$request.query.foo}'
            callback_model = Model.new
            operation_model = callback_model.add_operation(expression, 'bar')
            assert(operation_model.equal?(callback_model.operations[expression]))
            assert_equal('bar', operation_model.name)

            error = assert_raises(ArgumentError) do
              callback_model.add_operation('', 'bar')
            end
            assert_equal("expression can't be blank", error.message)
          end

          def test_callback_object
            expression = '{$request.query.foo}'
            callback_model = Model.new
            callback_model.add_operation(expression, 'bar')

            %w[3.0 3.1].each do |version|
              assert_equal(
                {
                  expression => {
                    'get' => {
                      operationId: 'bar',
                      parameters: [],
                      responses: {}
                    }
                  }
                },
                callback_model.to_openapi(version, nil)
              )
            end
          end
        end
      end
    end
  end
end
