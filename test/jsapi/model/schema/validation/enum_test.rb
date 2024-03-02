# frozen_string_literal: true

require 'test_helper'

require_relative 'dummy'

module Jsapi
  module Model
    module Schema
      module Validation
        class EnumTest < Minitest::Test
          def test_raises_error_on_invalid_enum
            error = assert_raises(ArgumentError) { Enum.new(nil) }
            assert_equal('invalid enum: ', error.message)
          end

          def test_positive_validation
            enum = Enum.new(%w[A B C])
            dummy = Dummy.new('A')

            enum.validate(dummy)
            assert_predicate(dummy.errors, :none?)
          end

          def test_negative_validation
            enum = Enum.new(%w[A B C])
            dummy = Dummy.new('D')

            enum.validate(dummy)
            assert_equal(['is not included in the list'], dummy.errors.map(&:message))
          end

          def test_json_schema_validation
            assert_equal(
              { enum: %w[foo bar] },
              Enum.new(%w[foo bar]).to_json_schema_validation
            )
          end

          def test_openapi_validation
            assert_equal(
              { enum: %w[foo bar] },
              Enum.new(%w[foo bar]).to_openapi_validation
            )
          end
        end
      end
    end
  end
end
