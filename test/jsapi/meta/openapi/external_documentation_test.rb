# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ExternalDocumentationTest < Minitest::Test
        def test_empty_external_documentation_object
          assert_equal({}, ExternalDocumentation.new.to_h)
        end

        def test_full_external_documentation_object
          assert_equal(
            {
              description: 'Foo',
              url: 'https://foo.bar/docs'
            },
            ExternalDocumentation.new(
              description: 'Foo',
              url: 'https://foo.bar/docs'
            ).to_h
          )
        end
      end
    end
  end
end
