# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      def test_description
        response_model = Model::Response.new
        Response.new(response_model).call { description 'Foo' }
        assert_equal('Foo', response_model.description)
      end

      def test_example
        response_model = Model::Response.new
        Response.new(response_model).call { example value: 'foo' }
        assert_equal('foo', response_model.examples['default'].value)
      end

      def test_example_with_block
        response_model = Model::Response.new
        Response.new(response_model).call do
          example { value 'foo' }
        end
        assert_equal('foo', response_model.examples['default'].value)
      end

      def test_delegated_method
        response_model = Model::Response.new(type: 'string')
        Response.new(response_model).call { format 'date' }
        assert_equal('date', response_model.schema.format)
      end
    end
  end
end
