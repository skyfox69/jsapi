# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ResponseTest < Minitest::Test
      def test_new_model
        response = Response.new(type: 'string')
        assert_kind_of(Response::Model, response)
      end

      def test_new_reference
        response = Response.new(ref: 'foo')
        assert_kind_of(Response::Reference, response)
      end
    end
  end
end
