# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ServerVariableTest < Minitest::Test
      def test_empty_openapi_server_variable_object
        assert_equal({}, ServerVariable.new.to_openapi)
      end

      def test_full_openapi_server_object
        server_variable = ServerVariable.new(
          enum: %w[foo bar],
          default: 'foo',
          description: 'Foo',
          openapi_extensions: { 'foo' => 'bar' }
        )
        assert_equal(
          {
            enum: %w[foo bar],
            default: 'foo',
            description: 'Foo',
            'x-foo': 'bar'
          },
          server_variable.to_openapi
        )
      end
    end
  end
end
