# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class BaseTest < Minitest::Test
        def test_example
          response = Base.new(type: 'string', example: 'foo')
          assert_equal('foo', response.examples['default'].value)
        end

        def test_openapi_response_2_0
          response = Base.new(type: 'string', existence: false, example: 'foo')

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
        end

        def test_minimal_openapi_response_2_0
          response = Base.new(type: 'string', existence: true)

          assert_equal(
            {
              schema: {
                type: 'string'
              }
            },
            response.to_openapi_response('2.0')
          )
        end

        def test_openapi_response_3_0
          response = Base.new(type: 'string', existence: false, example: 'foo')

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
              }
            },
            response.to_openapi_response('3.0')
          )
        end

        def test_minimal_openapi_response_3_0
          response = Base.new(type: 'string', existence: true)

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
      end
    end
  end
end
