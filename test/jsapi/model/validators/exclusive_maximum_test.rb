# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class ExclusiveMaximumTest < Minitest::Test
        def test_argument_error
          error = assert_raises(ArgumentError) { ExclusiveMaximum.new(nil) }
          assert_equal('invalid exclusive maximum: ', error.message)
        end

        def test_positive_validation
          validator = ExclusiveMaximum.new(0)
          errors = Validation::Errors.new

          validator.validate(-1, errors)
          assert_predicate(errors, :none?)
        end

        def test_negative_validation
          validator = ExclusiveMaximum.new(0)
          errors = Validation::Errors.new

          validator.validate(0, errors)
          assert_equal(['must be less than 0'], errors.map(&:message))
        end
      end
    end
  end
end
