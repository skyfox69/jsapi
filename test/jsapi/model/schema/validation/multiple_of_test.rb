# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class MultipleOfTest < Minitest::Test
          def test_raises_error_on_invalid_multiple_of
            error = assert_raises(ArgumentError) { MultipleOf.new(nil) }
            assert_equal('invalid multiple of: ', error.message)
          end

          def test_positive_validation
            multiple_of = MultipleOf.new(2)
            dummy = Dummy.new(4)

            multiple_of.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            multiple_of = MultipleOf.new(2)
            dummy = Dummy.new(3)

            multiple_of.validate(dummy)
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_json_schema_validation
            assert_equal(
              { multipleOf: 2 },
              MultipleOf.new(2).to_json_schema_validation
            )
          end

          def test_openapi_validation
            assert_equal(
              { multipleOf: 2 },
              MultipleOf.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
