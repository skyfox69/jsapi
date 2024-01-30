# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validators
    class LambdaValidatorTest < Minitest::Test
      LAMBDA = ->(_wrapper) { errors.add(:invalid) unless self == 'foo' }

      def test_validate_positive
        validator = LambdaValidator.new(LAMBDA)
        errors = Validation::Errors.new

        validator.validate('foo', errors)
        assert_predicate(errors, :none?)
      end

      def test_validate_negative
        validator = LambdaValidator.new(LAMBDA)
        errors = Validation::Errors.new

        validator.validate('bar', errors)
        assert_equal(['is invalid'], errors.map(&:message))
      end

      def test_validate_skipped
        validator = LambdaValidator.new(nil)
        errors = Validation::Errors.new

        validator.validate('foo', errors)
        assert_predicate(errors, :none?)
      end
    end
  end
end
