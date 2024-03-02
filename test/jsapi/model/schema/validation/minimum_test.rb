# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class MinimumTest < Minitest::Test
          def test_raises_error_on_invalid_minimum
            error = assert_raises(ArgumentError) { Minimum.new(nil) }
            assert_equal('invalid minimum: ', error.message)
          end

          def test_raises_error_on_invalid_exclusive_minimum
            error = assert_raises(ArgumentError) { Minimum.new(nil, exclusive: true) }
            assert_equal('invalid exclusive minimum: ', error.message)
          end

          def test_positive_minimum_validation
            minimum = Minimum.new(0)
            dummy = Dummy.new(0)

            minimum.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_minimum_validation
            minimum = Minimum.new(0)
            dummy = Dummy.new(-1)

            minimum.validate(dummy)
            assert_equal(
              ['must be greater than or equal to 0'],
              dummy.errors.map(&:message)
            )
          end

          def test_positive_exclusive_minimum_validation
            minimum = Minimum.new(0, exclusive: true)
            dummy = Dummy.new(1)

            minimum.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_exclusive_minimum_validation
            minimum = Minimum.new(0, exclusive: true)
            dummy = Dummy.new(0)

            minimum.validate(dummy)
            assert_equal(['must be greater than 0'], dummy.errors.map(&:message))
          end

          # JSON Schema tests

          def test_json_schema_minimum_validation
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_json_schema_validation
            )
          end

          def test_json_schema_exclusive_minimum_validation
            assert_equal(
              { exclusiveMinimum: 0 },
              Minimum.new(0, exclusive: true).to_json_schema_validation
            )
          end

          # OpenAPI tests

          def test_openapi_3_0_minimum_validation
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_openapi_validation('3.0')
            )
          end

          def test_openapi_3_0_exclusive_minimum_validation
            assert_equal(
              {
                minimum: 0,
                exclusiveMinimum: true
              },
              Minimum.new(0, exclusive: true).to_openapi_validation('3.0')
            )
          end

          def test_openapi_3_1_minimum_validation
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_openapi_validation('3.1')
            )
          end

          def test_openapi_3_1_exclusive_minimum_validation
            assert_equal(
              { exclusiveMinimum: 0 },
              Minimum.new(0, exclusive: true).to_openapi_validation('3.1')
            )
          end
        end
      end
    end
  end
end
