# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class MaximumTest < Minitest::Test
        def test_argument_error
          error = assert_raises(ArgumentError) { Maximum.new(nil) }
          assert_equal('invalid maximum: ', error.message)
        end

        def test_positive_validation
          validator = Maximum.new(0)
          errors = Validation::Errors.new

          validator.validate(0, errors)
          assert_predicate(errors, :none?)
        end

        def test_negative_validation
          validator = Maximum.new(0)
          errors = Validation::Errors.new

          validator.validate(1, errors)
          assert_equal(
            ['must be less than or equal to 0'],
            errors.map(&:message)
          )
        end
      end
    end
  end
end
