# frozen_string_literal: true

require 'test_helper'

module Jsapi
  class DSLTest < Minitest::Test
    class Foo
      include DSL

      api_parameter 'request_id', type: 'string'

      api_schema :ErrorResponse do
        property 'code', type: 'integer'
        property 'detail', type: 'string'
      end
    end

    class Bar < Foo
      api_definitions do
        include Foo
        info name: 'Bar API', version: '1.0'

        path '/my_path' do
          operation :get, 'my_operation' do
            parameter 'request_id', '$ref': :request_id
            parameter 'my_parameter', type: 'string', required: true
            response do
              property 'my_property', type: 'string'
            end
            response 400, '$ref': :ErrorResponse
          end
        end
      end
    end

    def test_it_all_together
      assert_equal(
        {
          openapi: '3.0.3',
          info: {
            name: 'Bar API',
            version: '1.0'
          },
          paths: {
            '/my_path' => {
              'get' => {
                operationId: 'my_operation',
                deprecated: false,
                parameters: [
                  {
                    '$ref': '#/components/parameters/request_id'
                  },
                  {
                    name: 'my_parameter',
                    required: true,
                    deprecated: false,
                    schema: {
                      type: 'string'
                    }
                  }
                ],
                responses: {
                  'default' => {
                    content: {
                      'application/json' => {
                        schema: {
                          type: 'object',
                          properties: {
                            'my_property' => {
                              type: 'string'
                            }
                          },
                          required: []
                        }
                      }
                    }
                  },
                  400 => {
                    content: {
                      'application/json' => {
                        schema: {
                          '$ref': '#/components/schemas/ErrorResponse'
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          components: {
            parameters: {
              'request_id' => {
                name: 'request_id',
                required: false,
                deprecated: false,
                schema: {
                  type: 'string'
                }
              }
            },
            schemas: {
              'ErrorResponse' => {
                type: 'object',
                properties: {
                  'code' => {
                    type: 'integer'
                  },
                  'detail' => {
                    type: 'string'
                  }
                },
                required: []
              }
            }
          }
        },
        Bar.api_definitions.openapi_document
      )
    end
  end
end
