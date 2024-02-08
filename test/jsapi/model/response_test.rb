# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ResponseTest < Minitest::Test
      def test_minimal_response
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
          response.to_openapi_response
        )
      end
    end
  end
end
