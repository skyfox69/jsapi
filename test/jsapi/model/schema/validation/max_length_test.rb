# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class MaxLengthTest < Minitest::Test
          def test_raises_error_on_invalid_max_length
            error = assert_raises(ArgumentError) { MaxLength.new(nil) }
            assert_equal('invalid max length: ', error.message)
          end

          def test_positive_validation
            max_length = MaxLength.new(3)
            dummy = Dummy.new('foo')

            max_length.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            max_length = MaxLength.new(2)
            dummy = Dummy.new('foo')

            max_length.validate(dummy)
            assert_equal(
              ['is too long (maximum is 2 characters)'],
              dummy.errors.map(&:message)
            )
          end

          def test_json_schema_validation
            assert_equal(
              { maxLength: 2 },
              MaxLength.new(2).to_json_schema_validation
            )
          end

          def test_openapi_validation
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
