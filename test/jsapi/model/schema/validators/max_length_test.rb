# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validators
        class MaxLengthTest < Minitest::Test
          def test_raises_error_on_invalid_max_length
            error = assert_raises(ArgumentError) { MaxLength.new(nil) }
            assert_equal('invalid max length: ', error.message)
          end

          def test_positive_validation
            validator = MaxLength.new(3)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            validator = MaxLength.new(2)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_equal(
              ['is too long (maximum is 2 characters)'],
              dummy.errors.map(&:message)
            )
          end
        end
      end
    end
  end
end
