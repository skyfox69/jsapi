# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ResponseTest < Minitest::Test
      def test_example
        response = Response.new(type: 'string', example: 'foo')
        assert_equal('foo', response.examples['default'].value)
      end

      def test_openapi_response_2_0
        response = Response.new(type: 'string', existence: false, example: 'foo')

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
        response = Response.new(type: 'string', existence: true)

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
        response = Response.new(type: 'string', existence: false, example: 'foo')

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
        response = Response.new(type: 'string', existence: true)

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

      def test_raises_error_on_unsupported_openapi_version
        response = Response.new(type: 'string')
        error = assert_raises(ArgumentError) do
          response.to_openapi_response('foo')
        end
        assert_equal('unsupported OpenAPI version: foo', error.message)
      end
    end
  end
end
