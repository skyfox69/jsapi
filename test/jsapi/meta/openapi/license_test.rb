# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class LicenseTest < Minitest::Test
        def test_empty_license_object
          assert_equal({}, License.new.to_h)
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
            ).to_h
          )
        end
      end
    end
  end
end
