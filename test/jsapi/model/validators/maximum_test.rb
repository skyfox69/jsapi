# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Validators
      class MaximumTest < Minitest::Test
        def test_invalid_maximum
          error = assert_raises(ArgumentError) { Maximum.new(nil) }
          assert_equal('invalid maximum: ', error.message)
        end

        def test_positive_validation
          validator = Maximum.new(0)
          dummy = Dummy.new(0)

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end

        def test_negative_validation
          validator = Maximum.new(0)
          dummy = Dummy.new(1)

          validator.validate(dummy)
          assert_equal(
            ['must be less than or equal to 0'],
            dummy.errors.map(&:message)
          )
        end
      end
    end
  end
end
