# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validators
        class MinLengthTest < Minitest::Test
          def test_raises_error_on_invalid_min_length
            error = assert_raises(ArgumentError) { MinLength.new(nil) }
            assert_equal('invalid min length: ', error.message)
          end

          def test_positive_validation
            validator = MinLength.new(3)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            validator = MinLength.new(4)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_equal(
              ['is too short (minimum is 4 characters)'],
              dummy.errors.map(&:message)
            )
          end
        end
      end
    end
  end
end
