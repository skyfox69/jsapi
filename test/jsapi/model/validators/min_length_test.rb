# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class MinLengthTest < Minitest::Test
        def test_raises_argument_error
          error = assert_raises(ArgumentError) { MinLength.new(nil) }
          assert_equal('invalid min length: ', error.message)
        end

        def test_validate_positive
          validator = MinLength.new(3)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_predicate(errors, :none?)
        end

        def test_validate_negative
          validator = MinLength.new(4)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_equal(['is too short (minimum is 4 characters)'], errors.map(&:message))
        end
      end
    end
  end
end
