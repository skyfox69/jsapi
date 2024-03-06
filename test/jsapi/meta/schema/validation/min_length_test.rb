# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MinLengthTest < Minitest::Test
          def test_raises_error_on_invalid_min_length
            error = assert_raises(ArgumentError) { MinLength.new(nil) }
            assert_equal('invalid min length: ', error.message)
          end

          def test_validates_min_length
            min_length = MinLength.new(3)

            min_length.validate(dummy = Dummy.new('foo'))
            assert_predicate(dummy.errors, :none?)

            min_length.validate(dummy = Dummy.new('fo'))
            assert_equal(
              ['is too short (minimum is 3 characters)'],
              dummy.errors.map(&:message)
            )
          end

          def test_to_json_schema_validation
            assert_equal(
              { minLength: 2 },
              MinLength.new(2).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { minLength: 2 },
              MinLength.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
