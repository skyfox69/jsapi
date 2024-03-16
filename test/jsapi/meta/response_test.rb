# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ResponseTest < Minitest::Test
      def test_new
        response = Response.new(type: 'string')
        assert_kind_of(Response::Base, response)
      end

      def test_reference
        reference = Response.reference('Foo')
        assert_kind_of(Response::Reference, reference)
      end
    end
  end
end
