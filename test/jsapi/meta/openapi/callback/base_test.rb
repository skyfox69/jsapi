# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        class BaseTest < Minitest::Test
          def test_operations
            expression = '{$request.query.foo}'
            callback = Base.new
            operation = callback.add_operation(expression, 'bar')
            assert(operation.equal?(callback.operations[expression]))
            assert_equal('bar', operation.name)

            error = assert_raises(ArgumentError) do
              callback.add_operation('', 'bar')
            end
            assert_equal("expression can't be blank", error.message)
          end

          def test_callback_object
            expression = '{$request.query.foo}'
            callback = Base.new
            callback.add_operation(expression, 'bar')

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
                callback.to_openapi(version, nil)
              )
            end
          end
        end
      end
    end
  end
end
