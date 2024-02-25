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
        Response.new(response_model).call { example 'Foo' }
        assert_equal('Foo', response_model.example)
      end

      def test_delegated_method
        response_model = Model::Response.new(type: 'string')
        Response.new(response_model).call { format 'date' }
        assert_equal('date', response_model.schema.format)
      end
    end
  end
end
