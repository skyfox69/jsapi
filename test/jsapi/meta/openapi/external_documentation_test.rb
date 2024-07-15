# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ExternalDocumentationTest < Minitest::Test
        def test_empty_openapi_external_documentation_object
          assert_equal({}, ExternalDocumentation.new.to_openapi)
        end

        def test_full_openapi_external_documentation_object
          external_documentation = ExternalDocumentation.new(
            url: 'https://foo.bar/docs',
            description: 'Foo'
          )
          external_documentation.add_openapi_extension('foo', 'bar')

          assert_equal(
            {
              url: 'https://foo.bar/docs',
              description: 'Foo',
              'x-foo': 'bar'
            },
            external_documentation.to_openapi
          )
        end
      end
    end
  end
end
