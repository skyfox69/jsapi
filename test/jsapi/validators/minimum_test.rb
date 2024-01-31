# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validators
    class MinimumTest < Minitest::Test
      def test_raises_argument_error
        error = assert_raises(ArgumentError) { Minimum.new(nil) }
        assert_equal('invalid minimum: ', error.message)
      end

      def test_validate_positive
        validator = Minimum.new(0)
        errors = Validation::Errors.new

        validator.validate(0, errors)
        assert_predicate(errors, :none?)
      end

      def test_validate_negative
        validator = Minimum.new(0)
        errors = Validation::Errors.new

        validator.validate(-1, errors)
        assert_equal(['must be greater than or equal to 0'], errors.map(&:message))
      end
    end
  end
end
