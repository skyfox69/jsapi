# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class MaxItemsTest < Minitest::Test
          def test_raises_error_on_invalid_max_length
            error = assert_raises(ArgumentError) { MaxItems.new(nil) }
            assert_equal('invalid max items: ', error.message)
          end

          def test_positive_validation
            max_items = MaxItems.new(2)
            dummy = Dummy.new(%w[foo bar])

            max_items.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            max_items = MaxItems.new(2)
            dummy = Dummy.new(%w[foo bar foo])

            max_items.validate(dummy)
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_json_schema_validation
            assert_equal(
              { maxItems: 2 },
              MaxItems.new(2).to_json_schema_validation
            )
          end

          def test_openapi_validation
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
