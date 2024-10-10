# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Link
      class ReferenceTest < Minitest::Test
        def test_openapi_reference_object
          assert_equal(
            { '$ref': '#/components/links/foo' },
            Reference.new(ref: 'foo').to_openapi
          )
        end
      end
    end
  end
end
