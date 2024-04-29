# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ExternalDocumentationTest < Minitest::Test
        def test_empty_external_documentation_object
          assert_equal({}, ExternalDocumentation.new.to_openapi)
        end

        def test_full_external_documentation_object
          assert_equal(
            {
              url: 'https://foo.bar/docs',
              description: 'Foo'
            },
            ExternalDocumentation.new(
              url: 'https://foo.bar/docs',
              description: 'Foo'
            ).to_openapi
          )
        end
      end
    end
  end
end
