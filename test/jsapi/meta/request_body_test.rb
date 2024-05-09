# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class RequestBodyTest < Minitest::Test
      def test_new
        request_body = RequestBody.new(type: 'string')
        assert_kind_of(RequestBody::Base, request_body)
      end

      def test_new_reference
        response = RequestBody.new(ref: 'foo')
        assert_kind_of(RequestBody::Reference, response)
      end
    end
  end
end
