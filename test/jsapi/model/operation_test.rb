# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class OperationTest < Minitest::Test
      def test_raises_error_on_blank_name
        error = assert_raises(ArgumentError) { Operation.new('') }
        assert_equal("operation name can't be blank", error.message)
      end

      # OpenAPI tests

      def test_openapi_operation_2_0
        operation = Operation.new('foo')
        operation.add_parameter('bar', type: 'string', in: 'query')
        operation.set_request_body(type: 'string', existence: true)
        operation.add_response(type: 'string')

        assert_equal(
          {
            operationId: 'foo',
            parameters: [
              {
                name: 'bar',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              },
              {
                name: 'body',
                in: 'body',
                required: true,
                type: 'string'
              }
            ],
            responses: {
              'default' => {
                schema: {
                  type: 'string'
                }
              }
            }
          },
          operation.to_openapi_operation('2.0', Definitions.new)
        )
      end

      def test_openapi_operation_3_0
        operation = Operation.new('foo')
        operation.add_parameter('bar', type: 'string', in: 'query')
        operation.set_request_body(type: 'string', existence: true)
        operation.add_response(type: 'string')

        assert_equal(
          {
            operationId: 'foo',
            parameters: [
              {
                name: 'bar',
                in: 'query',
                schema: {
                  type: 'string',
                  nullable: true
                },
                allowEmptyValue: true
              }
            ],
            request_body: {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string'
                  }
                }
              },
              required: true
            },
            responses: {
              'default' => {
                content: {
                  'application/json' => {
                    schema: {
                      type: 'string',
                      nullable: true
                    }
                  }
                }
              }
            }
          },
          operation.to_openapi_operation('3.0.3', Definitions.new)
        )
      end
    end
  end
end
