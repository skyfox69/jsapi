# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class OperationTest < Minitest::Test
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
                required: false,
                type: 'string'
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
          operation.to_openapi_operation('2.0')
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
                required: false,
                schema: {
                  type: 'string',
                  nullable: true
                }
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
          operation.to_openapi_operation('3.0.3')
        )
      end
    end
  end
end
