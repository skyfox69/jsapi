# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class RequestBodyTest < Minitest::Test
      def test_minimal_request_body
        request_body = RequestBody.new(type: 'string')

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
            required: false
          },
          request_body.to_openapi_request_body
        )
      end
    end
  end
end
