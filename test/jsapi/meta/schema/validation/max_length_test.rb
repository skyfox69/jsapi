# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Meta
    module Schema
      module Validation
        class MaxLengthTest < Minitest::Test
          def test_raises_error_on_invalid_max_length
            error = assert_raises(ArgumentError) { MaxLength.new(nil) }
            assert_equal('invalid max length: ', error.message)
          end

          def test_validates_max_length
            max_length = MaxLength.new(3)

            max_length.validate(dummy = Dummy.new('foo'))
            assert_predicate(dummy.errors, :none?)

            max_length.validate(dummy = Dummy.new('foo bar'))
            assert_equal(
              ['is too long (maximum is 3 characters)'],
              dummy.errors.map(&:message)
            )
          end

          def test_to_json_schema_validation
            assert_equal(
              { maxLength: 2 },
              MaxLength.new(2).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
            assert_equal(
              { maxLength: 2 },
              MaxLength.new(2).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
