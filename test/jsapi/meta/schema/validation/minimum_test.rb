# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MinimumTest < Minitest::Test
          def test_raises_error_on_invalid_minimum
            error = assert_raises(ArgumentError) { Minimum.new(nil) }
            assert_equal('invalid minimum: nil', error.message)
          end

          def test_raises_error_on_invalid_exclusive_minimum
            error = assert_raises(ArgumentError) { Minimum.new(nil, exclusive: true) }
            assert_equal('invalid exclusive minimum: nil', error.message)
          end

          def test_validates_minimum
            minimum = Minimum.new(0)

            errors = Model::Errors.new
            assert(minimum.validate(0, errors))
            assert_predicate(errors, :empty?)

            errors = Model::Errors.new
            assert(!minimum.validate(-1, errors))
            assert(errors.added?(:base, 'must be greater than or equal to 0'))
          end

          def test_validates_exclusive_minimum
            minimum = Minimum.new(0, exclusive: true)

            errors = Model::Errors.new
            assert(minimum.validate(1, errors))
            assert_predicate(errors, :empty?)

            errors = Model::Errors.new
            assert(!minimum.validate(0, errors))
            assert(errors.added?(:base, 'must be greater than 0'))
          end

          # JSON Schema tests

          def test_to_json_schema_on_minimum
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_json_schema_validation
            )
          end

          def test_to_json_schema_on_exclusive_minimum
            assert_equal(
              { exclusiveMinimum: 0 },
              Minimum.new(0, exclusive: true).to_json_schema_validation
            )
          end

          # OpenAPI tests

          def test_to_openapi_3_0_on_minimum
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_openapi_validation('3.0')
            )
          end

          def test_to_openapi_3_0_on_exclusive_minimum
            assert_equal(
              {
                minimum: 0,
                exclusiveMinimum: true
              },
              Minimum.new(0, exclusive: true).to_openapi_validation('3.0')
            )
          end

          def test_to_openapi_3_1_on_minimum
            assert_equal(
              { minimum: 0 },
              Minimum.new(0).to_openapi_validation('3.1')
            )
          end

          def test_to_openapi_3_1_on_exclusive_minimum
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
