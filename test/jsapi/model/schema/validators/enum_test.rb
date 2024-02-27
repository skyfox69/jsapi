# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validators
        class EnumTest < Minitest::Test
          def test_raises_error_on_invalid_enum
            error = assert_raises(ArgumentError) { Enum.new(nil) }
            assert_equal('invalid enum: ', error.message)
          end

          def test_positive_validation
            validator = Enum.new(%w[A B C])
            dummy = Dummy.new('A')

            validator.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            validator = Enum.new(%w[A B C])
            dummy = Dummy.new('D')

            validator.validate(dummy)
            assert_equal(['is not included in the list'], dummy.errors.map(&:message))
          end
        end
      end
    end
  end
end
