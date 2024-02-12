# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class LambdaValidatorTest < Minitest::Test
        LAMBDA = ->(_wrapper) { errors.add(:invalid) unless self == 'foo' }

        def test_positive_validation
          validator = LambdaValidator.new(LAMBDA)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_predicate(errors, :none?)
        end

        def test_negative_validation
          validator = LambdaValidator.new(LAMBDA)
          errors = Validation::Errors.new

          validator.validate('bar', errors)
          assert_equal(['is invalid'], errors.map(&:message))
        end

        def test_nil_validator
          validator = LambdaValidator.new(nil)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_predicate(errors, :none?)
        end
      end
    end
  end
end
