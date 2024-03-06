# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MaxItemsTest < Minitest::Test
          def test_raises_error_on_invalid_max_length
            error = assert_raises(ArgumentError) { MaxItems.new(nil) }
            assert_equal('invalid max items: ', error.message)
          end

          def test_validates_max_items
            max_items = MaxItems.new(2)

            max_items.validate(dummy = Dummy.new(%w[foo bar]))
            assert_predicate(dummy.errors, :none?)

            max_items.validate(dummy = Dummy.new(%w[foo bar foo]))
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_to_json_schema_validation
            assert_equal(
              { maxItems: 2 },
              MaxItems.new(2).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { maxItems: 2 },
              MaxItems.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
