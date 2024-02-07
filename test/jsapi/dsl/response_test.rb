# frozen_string_literal: true

module Jsapi
  module DSL
    class ResponseTest < Minitest::Test
      def test_description
        response_model = Model::Response.new
        Response.new(response_model).call { description 'My description' }
        assert_equal('My description', response_model.description)
      end

      def test_example
        response_model = Model::Response.new
        Response.new(response_model).call { example 'My example' }
        assert_equal('My example', response_model.example)
      end

      def test_nullable
        response_model = Model::Response.new
        Response.new(response_model).call { nullable true }
        assert(response_model.schema.nullable?)
      end

      def test_a_delegated_method
        response_model = Model::Response.new(type: 'string')
        Response.new(response_model).call { format 'date' }
        assert_equal('date', response_model.schema.format)
      end
    end
  end
end
