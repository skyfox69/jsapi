# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ExtensionsTest < Minitest::Test
        include Extensions

        def test_add_openapi_extension
          add_openapi_extension('foo', 'bar')
          assert_equal('bar', openapi_extensions[:'x-foo'])
        end

        def test_add_openapi_extension_raises_an_error_when_name_is_blank
          error = assert_raises(ArgumentError) do
            add_openapi_extension('')
          end
          assert_equal("name can't be blank", error.message)
        end
      end
    end
  end
end
