# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBodyTest < Minitest::Test
      def test_annotations
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call do
          description 'My description'
          example 'My example'
        end
        assert_equal(
          {
            description: 'My description',
            example: 'My example'
          },
          request_body_model.to_openapi_request_body.except(:content, :required)
        )
      end

      def test_required
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call { required true }

        assert(request_body_model.required?)
      end

      def test_delegated_methods
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call do
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
          request_body_model.to_openapi_request_body[:content]
        )
      end
    end
  end
end
