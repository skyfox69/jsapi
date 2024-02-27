# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Validators
      class ExclusiveMaximumTest < Minitest::Test
        def test_raises_error_on_invalid_exclusive_maximum
          error = assert_raises(ArgumentError) { ExclusiveMaximum.new(nil) }
          assert_equal('invalid exclusive maximum: ', error.message)
        end

        def test_positive_validation
          validator = ExclusiveMaximum.new(0)
          dummy = Dummy.new(-1)

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end

        def test_negative_validation
          validator = ExclusiveMaximum.new(0)
          dummy = Dummy.new(0)

          validator.validate(dummy)
          assert_equal(['must be less than 0'], dummy.errors.map(&:message))
        end
      end
    end
  end
end
