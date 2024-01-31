# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validators
    class ExclusiveMinimumTest < Minitest::Test
      def test_raises_argument_error
        error = assert_raises(ArgumentError) { ExclusiveMinimum.new(nil) }
        assert_equal('Invalid exclusive minimum: ', error.message)
      end

      def test_validate_positive
        validator = ExclusiveMinimum.new(0)
        errors = Validation::Errors.new

        validator.validate(1, errors)
        assert_predicate(errors, :none?)
      end

      def test_validate_negative
        validator = ExclusiveMinimum.new(0)
        errors = Validation::Errors.new

        validator.validate(0, errors)
        assert_equal(['must be greater than 0'], errors.map(&:message))
      end
    end
  end
end