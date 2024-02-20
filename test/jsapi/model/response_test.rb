# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ResponseTest < Minitest::Test
      def test_openapi_response_2_0
        response = Response.new(type: 'string', existence: false, example: 'foo')

        assert_equal(
          {
            schema: {
              type: 'string'
            },
            examples: 'foo'
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
                }
              }
            },
            example: 'foo'
          },
          response.to_openapi_response('3.0.3')
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
          response.to_openapi_response('3.0.3')
        )
      end
    end
  end
end
