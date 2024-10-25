# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Callback
      class BaseTest < Minitest::Test
        def test_operations
          expression = '{$request.query.foo}'

          callback = Base.new
          assert_nil(callback.operation(expression))

          operation = callback.add_operation(expression, path: '/bar')
          assert(operation.equal?(callback.operation(expression)))
          assert_equal('/bar', operation.path)

          assert_nil(callback.operation(nil))

          error = assert_raises(ArgumentError) do
            callback.add_operation('', path: '/bar')
          end
          assert_equal("expression can't be blank", error.message)
        end

        def test_openapi_callback_object
          expression = '{$request.query.foo}'
          callback = Base.new
          callback.add_operation(expression)

          %w[3.0 3.1].each do |version|
            assert_equal(
              {
                expression => {
                  'get' => {
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
