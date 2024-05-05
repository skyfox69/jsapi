# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class BaseTest < Minitest::Test
        def test_type
          response = Base.new(type: 'string')
          assert_equal('string', response.type)
        end

        def test_example
          response = Base.new(type: 'string', example: 'foo')
          assert_equal('foo', response.example.value)
        end

        # OpenAPI tests

        def test_minimal_openapi_response_object
          response = Base.new(type: 'string', existence: true)

          # OpenAPI 2.0
          assert_equal(
            {
              schema: {
                type: 'string'
              }
            },
            response.to_openapi_response('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string'
                  }
                }
              }
            },
            response.to_openapi_response('3.0')
          )
        end

        def test_full_openapi_response_object
          response = Base.new(type: 'string', existence: false, example: 'foo')
          response.add_link('foo', operation_id: 'foo')

          # OpenAPI 2.0
          assert_equal(
            {
              schema: {
                type: 'string'
              },
              examples: {
                'application/json' => 'foo'
              }
            },
            response.to_openapi_response('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string',
                    nullable: true
                  },
                  examples: {
                    'default' => {
                      value: 'foo'
                    }
                  }
                }
              },
              links: {
                'foo' => {
                  operationId: 'foo'
                }
              }
            },
            response.to_openapi_response('3.0')
          )
        end
      end
    end
  end
end
