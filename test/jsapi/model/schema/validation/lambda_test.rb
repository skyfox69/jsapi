# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class LambdaTest < Minitest::Test
          def test_validates_by_lamba
            validator = Lambda.new(
              lambda do |value|
                errors.add(:invalid) unless value == 'foo'
              end
            )
            validator.validate(dummy = Dummy.new('foo'))
            assert_predicate(dummy.errors, :none?)

            validator.validate(dummy = Dummy.new('bar'))
            assert_equal(['is invalid'], dummy.errors.map(&:message))
          end

          def test_nil
            validator = Lambda.new(nil)

            dummy = Dummy.new('foo')
            validator.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end
        end
      end
    end
  end
end
