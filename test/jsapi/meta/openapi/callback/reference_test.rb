# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        class ReferenceTest < Minitest::Test
          def test_openapi_reference_object
            assert_equal(
              { '$ref': '#/components/callbacks/foo' },
              Reference.new(ref: 'foo').to_openapi
            )
          end
        end
      end
    end
  end
end
