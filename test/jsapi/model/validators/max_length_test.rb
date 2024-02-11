# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class MaxLengthTest < Minitest::Test
        def test_raises_argument_error
          error = assert_raises(ArgumentError) { MaxLength.new(nil) }
          assert_equal('invalid max length: ', error.message)
        end

        def test_validate_positive
          validator = MaxLength.new(3)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_predicate(errors, :none?)
        end

        def test_validate_negative
          validator = MaxLength.new(2)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_equal(['is too long (maximum is 2 characters)'], errors.map(&:message))
        end
      end
    end
  end
end
