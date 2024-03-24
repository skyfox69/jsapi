# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      def test_description
        response = Meta::Response.new
        Response.new(response).call { description 'Foo' }
        assert_equal('Foo', response.description)
      end

      def test_example
        response = Meta::Response.new
        Response.new(response).call { example value: 'foo' }
        assert_equal('foo', response.examples['default'].value)
      end

      def test_delegates_to_schema
        response = Meta::Response.new(type: 'string')
        Response.new(response).call { format 'date' }
        assert_equal('date', response.schema.format)
      end
    end
  end
end
