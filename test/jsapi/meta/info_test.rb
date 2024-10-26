# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class InfoTest < Minitest::Test
      def test_empty_openapi_info_object
        %w[2.0 3.0 3.1].each do |version|
          assert_equal({}, Info.new.to_openapi(version))
        end
      end

      def test_full_openapi_info_object
        info = Info.new(
          title: 'Foo',
          summary: 'Summary',
          description: 'Lorem ipsum',
          terms_of_service: 'Terms of service',
          contact: {
            name: 'Bar'
          },
          license: {
            name: 'MIT'
          },
          version: 1,
          openapi_extensions: { 'foo' => 'bar' }
        )
        # OpenAPI 2.0 and 3.0
        %w[2.0 3.0].each do |version|
          assert_equal(
            {
              title: 'Foo',
              description: 'Lorem ipsum',
              termsOfService: 'Terms of service',
              contact: {
                name: 'Bar'
              },
              license: {
                name: 'MIT'
              },
              version: '1',
              'x-foo': 'bar'
            },
            info.to_openapi(version)
          )
        end
        # OpenAPI 3.1
        assert_equal(
          {
            title: 'Foo',
            summary: 'Summary',
            description: 'Lorem ipsum',
            termsOfService: 'Terms of service',
            contact: {
              name: 'Bar'
            },
            license: {
              name: 'MIT'
            },
            version: '1',
            'x-foo': 'bar'
          },
          info.to_openapi('3.1')
        )
      end
    end
  end
end
