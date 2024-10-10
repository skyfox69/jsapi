# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class LicenseTest < Minitest::Test
      def test_empty_openapi_license_object
        assert_equal({}, License.new.to_openapi)
      end

      def test_full_openapi_license_object
        license = License.new(
          name: 'Foo',
          url: 'https://foo.bar/license',
          openapi_extensions: { 'foo' => 'bar' }
        )
        assert_equal(
          {
            name: 'Foo',
            url: 'https://foo.bar/license',
            'x-foo': 'bar'
          },
          license.to_openapi
        )
      end
    end
  end
end
