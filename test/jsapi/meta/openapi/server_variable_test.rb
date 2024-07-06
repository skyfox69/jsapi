# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ServerVariableTest < Minitest::Test
        def test_empty_server_variable_object
          assert_equal({}, ServerVariable.new.to_openapi)
        end

        def test_full_server_object
          server_variable = ServerVariable.new(
            enum: %w[foo bar],
            default: 'foo',
            description: 'Foo'
          )
          server_variable.add_openapi_extension('foo', 'bar')

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
end
