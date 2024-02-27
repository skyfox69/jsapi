# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Validators
      class MultipleOfTest < Minitest::Test
        def test_raises_error_on_invalid_multiple_of
          error = assert_raises(ArgumentError) { MultipleOf.new(nil) }
          assert_equal('invalid multiple of: ', error.message)
        end

        def test_positive_validation
          validator = MultipleOf.new(2)
          dummy = Dummy.new(4)

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end

        def test_negative_validation
          validator = MultipleOf.new(2)
          dummy = Dummy.new(3)

          validator.validate(dummy)
          assert_equal(['is invalid'], dummy.errors.map(&:message))
        end
      end
    end
  end
end
