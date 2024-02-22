# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Validators
      class LambdaTest < Minitest::Test
        def test_positive_validation
          validator = Lambda.new(
            lambda do |value|
              errors.add(:invalid) unless value == 'foo'
            end
          )
          dummy = Dummy.new('foo')

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end

        def test_negative_validation
          validator = Lambda.new(
            lambda do |value|
              errors.add(:invalid) if value == 'foo'
            end
          )
          dummy = Dummy.new('foo')

          validator.validate(dummy)
          assert_equal(['is invalid'], dummy.errors.map(&:message))
        end

        def test_nil_validator
          validator = Lambda.new(nil)
          dummy = Dummy.new('foo')

          validator.validate(dummy)
          assert_predicate(dummy.errors, :none?)
        end
      end
    end
  end
end
