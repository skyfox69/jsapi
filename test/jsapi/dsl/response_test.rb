# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      def test_annotations
        response_model = Model::Response.new
        Response.new(response_model).call do
          description 'My description'
          example 'My example'
        end
        assert_equal(
          {
            description: 'My description',
            example: 'My example'
          },
          response_model.to_openapi_response.except(:content)
        )
      end

      def test_delegated_methods
        response_model = Model::Response.new
        Response.new(response_model).call do
          nullable true
        end
        assert_equal(
          {
            'application/json' => {
              schema: {
                type: 'object',
                nullable: true,
                properties: {},
                required: []
              }
            }
          },
          response_model.to_openapi_response[:content]
        )
      end
    end
  end
end
