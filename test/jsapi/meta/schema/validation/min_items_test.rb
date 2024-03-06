# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MinItemsTest < Minitest::Test
          def test_raises_error_on_invalid_min_length
            error = assert_raises(ArgumentError) { MinItems.new(nil) }
            assert_equal('invalid min items: ', error.message)
          end

          def test_validates_min_items
            min_items = MinItems.new(2)

            min_items.validate(dummy = Dummy.new(%w[foo bar]))
            assert_predicate(dummy.errors, :none?)

            min_items.validate(dummy = Dummy.new(%w[foo]))
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_to_json_schema_validation
            assert_equal(
              { minItems: 2 },
              MinItems.new(2).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { minItems: 2 },
              MinItems.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
