# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class TagTest < Minitest::Test
        def test_external_docs
          tag = Tag.new
          tag.external_docs = { url: 'https://foo.bar/docs' }
          assert_equal('https://foo.bar/docs', tag.external_docs.url)
        end

        def test_empty_tag_object
          assert_equal({}, Tag.new.to_h)
        end

        def test_full_tag_object
          assert_equal(
            {
              name: 'Foo',
              description: 'Description of Foo',
              externalDocs: {
                url: 'https://foo.bar/docs'
              }
            },
            Tag.new(
              name: 'Foo',
              description: 'Description of Foo',
              external_docs: {
                url: 'https://foo.bar/docs'
              }
            ).to_h
          )
        end
      end
    end
  end
end
