# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Validators
      class ExclusiveMinimumTest < Minitest::Test
        def test_invalid_exclusive_minimum
          error = assert_raises(ArgumentError) { ExclusiveMinimum.new(nil) }
          assert_equal('invalid exclusive minimum: ', error.message)
        end

        def test_positive_validation
          validator = ExclusiveMinimum.new(0)
          dummy = Dummy.new(1)

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end

        def test_negative_validation
          validator = ExclusiveMinimum.new(0)
          dummy = Dummy.new(0)

          validator.validate(dummy)
          assert_equal(['must be greater than 0'], dummy.errors.map(&:message))
        end
      end
    end
  end
end
