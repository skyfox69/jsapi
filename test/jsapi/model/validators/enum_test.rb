# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class EnumTest < Minitest::Test
        def test_raises_argument_error
          error = assert_raises(ArgumentError) { Enum.new(nil) }
          assert_equal('invalid enum: ', error.message)
        end

        def test_validate_positive
          validator = Enum.new(%w[A B C])
          errors = Validation::Errors.new

          validator.validate('A', errors)
          assert_predicate(errors, :none?)
        end

        def test_validate_negative
          validator = Enum.new(%w[A B C])
          errors = Validation::Errors.new

          validator.validate('D', errors)
          assert_equal(['is not included in the list'], errors.map(&:message))
        end
      end
    end
  end
end
