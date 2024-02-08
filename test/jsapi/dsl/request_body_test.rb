# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBodyTest < Minitest::Test
      def test_description
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call { description 'My description' }
        assert_equal('My description', request_body_model.description)
      end

      def test_example
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call { example 'My example' }
        assert_equal('My example', request_body_model.example)
      end

      def test_a_delegated_method
        request_body_model = Model::RequestBody.new(type: 'string')
        RequestBody.new(request_body_model).call { format 'date' }
        assert_equal('date', request_body_model.schema.format)
      end
    end
  end
end
