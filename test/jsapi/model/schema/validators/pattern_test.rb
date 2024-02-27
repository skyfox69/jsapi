# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validators
        class PatternTest < Minitest::Test
          def test_raises_error_on_invalid_pattern
            error = assert_raises(ArgumentError) { Pattern.new(nil) }
            assert_equal('invalid pattern: ', error.message)
          end

          def test_positive_validation
            validator = Pattern.new(/fo/)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            validator = Pattern.new(/ba/)
            dummy = Dummy.new('foo')

            validator.validate(dummy)
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end
        end
      end
    end
  end
end
