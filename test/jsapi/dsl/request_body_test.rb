# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBodyTest < Minitest::Test
      def test_description
        request_body = Meta::RequestBody.new
        RequestBody.new(request_body).call { description 'Foo' }
        assert_equal('Foo', request_body.description)
      end

      def test_example
        request_body = Meta::RequestBody.new
        RequestBody.new(request_body).call { example value: 'foo' }
        assert_equal('foo', request_body.examples['default'].value)
      end

      def test_example_with_block
        request_body = Meta::RequestBody.new
        RequestBody.new(request_body).call do
          example { value 'foo' }
        end
        assert_equal('foo', request_body.examples['default'].value)
      end

      def test_delegates_to_schema
        request_body = Meta::RequestBody.new(type: 'string')
        RequestBody.new(request_body).call { format 'date' }
        assert_equal('date', request_body.schema.format)
      end
    end
  end
end
