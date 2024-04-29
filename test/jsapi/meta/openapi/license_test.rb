# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class LicenseTest < Minitest::Test
        def test_empty_license_object
          assert_equal({}, License.new.to_openapi)
        end

        def test_full_license_object
          assert_equal(
            {
              name: 'Foo',
              url: 'https://foo.bar/license'
            },
            License.new(
              name: 'Foo',
              url: 'https://foo.bar/license'
            ).to_openapi
          )
        end
      end
    end
  end
end
