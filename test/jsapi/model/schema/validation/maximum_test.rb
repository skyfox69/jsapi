# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class MaximumTest < Minitest::Test
          def test_raises_error_on_invalid_maximum
            error = assert_raises(ArgumentError) { Maximum.new(nil) }
            assert_equal('invalid maximum: ', error.message)
          end

          def test_raises_error_on_invalid_exclusive_maximum
            error = assert_raises(ArgumentError) { Maximum.new(nil, exclusive: true) }
            assert_equal('invalid exclusive maximum: ', error.message)
          end

          def test_validates_maximum
            maximum = Maximum.new(0)

            maximum.validate(dummy = Dummy.new(0))
            assert_predicate(dummy.errors, :none?)

            maximum.validate(dummy = Dummy.new(1))
            assert_equal(
              ['must be less than or equal to 0'],
              dummy.errors.map(&:message)
            )
          end

          def test_validates_exclusive_maximum
            exclusive_maximum = Maximum.new(0, exclusive: true)

            exclusive_maximum.validate(dummy = Dummy.new(-1))
            assert_predicate(dummy.errors, :none?)

            exclusive_maximum.validate(dummy = Dummy.new(0))
            assert_equal(['must be less than 0'], dummy.errors.map(&:message))
          end

          # JSON Schema tests

          def test_to_json_schema_on_maximum
            assert_equal(
              { maximum: 0 },
              Maximum.new(0).to_json_schema_validation
            )
          end

          def test_to_json_schema_on_exclusive_maximum
            assert_equal(
              { exclusiveMaximum: 0 },
              Maximum.new(0, exclusive: true).to_json_schema_validation
            )
          end

          # OpenAPI tests

          def test_to_openapi_3_0_on_maximum
            assert_equal(
              { maximum: 0 },
              Maximum.new(0).to_openapi_validation('3.0')
            )
          end

          def test_to_openapi_3_0_on_exclusive_maximum
            assert_equal(
              {
                maximum: 0,
                exclusiveMaximum: true
              },
              Maximum.new(0, exclusive: true).to_openapi_validation('3.0')
            )
          end

          def test_to_openapi_3_1_on_maximum
            assert_equal(
              { maximum: 0 },
              Maximum.new(0).to_openapi_validation('3.1')
            )
          end

          def test_to_openapi_3_1_on_exclusive_maximum
            assert_equal(
              { exclusiveMaximum: 0 },
              Maximum.new(0, exclusive: true).to_openapi_validation('3.1')
            )
          end
        end
      end
    end
  end
end
