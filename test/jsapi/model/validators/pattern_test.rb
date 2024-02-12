# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Validators
      class PatternTest < Minitest::Test
        def test_argument_error
          error = assert_raises(ArgumentError) { Pattern.new(nil) }
          assert_equal('invalid pattern: ', error.message)
        end

        def test_positive_validation
          validator = Pattern.new(/fo/)
          errors = Validation::Errors.new

          validator.validate('foo', errors)
          assert_predicate(errors, :none?)
        end

        def test_negative_validation
          validator = Pattern.new(/fo/)
          errors = Validation::Errors.new

          validator.validate('bar', errors)
          assert_equal(['is invalid'], errors.map(&:message))
        end
      end
    end
  end
end
