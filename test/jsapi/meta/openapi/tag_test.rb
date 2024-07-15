# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class TagTest < Minitest::Test
        def test_empty_openapi_tag_object
          assert_equal({}, Tag.new.to_openapi)
        end

        def test_full_openapi_tag_object
          tag = Tag.new(
            name: 'Foo',
            description: 'Description of Foo',
            external_docs: {
              url: 'https://foo.bar/docs'
            }
          )
          tag.add_openapi_extension('foo', 'bar')

          assert_equal(
            {
              name: 'Foo',
              description: 'Description of Foo',
              externalDocs: {
                url: 'https://foo.bar/docs'
              },
              'x-foo': 'bar'
            },
            tag.to_openapi
          )
        end
      end
    end
  end
end
