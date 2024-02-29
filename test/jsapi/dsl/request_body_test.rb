# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBodyTest < Minitest::Test
      def test_description
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call { description 'Foo' }
        assert_equal('Foo', request_body_model.description)
      end

      def test_example
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call { example value: 'foo' }
        assert_equal('foo', request_body_model.examples['default'].value)
      end

      def test_example_with_block
        request_body_model = Model::RequestBody.new
        RequestBody.new(request_body_model).call do
          example { value 'foo' }
        end
        assert_equal('foo', request_body_model.examples['default'].value)
      end

      def test_delegated_method
        request_body_model = Model::RequestBody.new(type: 'string')
        RequestBody.new(request_body_model).call { format 'date' }
        assert_equal('date', request_body_model.schema.format)
      end
    end
  end
end
