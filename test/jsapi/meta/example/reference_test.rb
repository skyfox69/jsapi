# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Example
      class ReferenceTest < Minitest::Test
        def test_reference_object
          assert_equal(
            { '$ref': '#/components/examples/foo' },
            Reference.new(ref: 'foo').to_openapi
          )
        end
      end
    end
  end
end
