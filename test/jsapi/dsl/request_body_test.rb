# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBodyTest < Minitest::Test
      def test_example
        request_body = Meta::RequestBody.new
        RequestBody.new(request_body) { example 'foo' }
        assert_equal('foo', request_body.example('default').value)
      end
    end
  end
end
