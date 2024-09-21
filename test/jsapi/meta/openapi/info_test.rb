# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class InfoTest < Minitest::Test
        def test_empty_openapi_info_object
          assert_equal({}, Info.new.to_openapi)
        end

        def test_full_openapi_info_object
          info = Info.new(
            title: 'Foo',
            version: 1,
            description: 'Description of Foo',
            terms_of_service: 'Terms of service',
            contact: {
              name: 'Bar'
            },
            license: {
              name: 'MIT'
            },
            openapi_extensions: { 'foo' => 'bar' }
          )
          assert_equal(
            {
              title: 'Foo',
              version: '1',
              description: 'Description of Foo',
              termsOfService: 'Terms of service',
              contact: {
                name: 'Bar'
              },
              license: {
                name: 'MIT'
              },
              'x-foo': 'bar'
            },
            info.to_openapi
          )
        end
      end
    end
  end
end
