# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      module Validation
        class EnumTest < Minitest::Test
          def test_raises_error_on_invalid_enum
            error = assert_raises(ArgumentError) { Enum.new(nil) }
            assert_equal('invalid enum: ', error.message)
          end

          def test_validates_enum
            enum = Enum.new(%w[A B C])

            enum.validate(dummy = Dummy.new('A'))
            assert_predicate(dummy.errors, :none?)

            enum.validate(dummy = Dummy.new('D'))
            assert_equal(['is not included in the list'], dummy.errors.map(&:message))
          end

          def test_to_json_schema_validation
            assert_equal(
              { enum: %w[foo bar] },
              Enum.new(%w[foo bar]).to_json_schema_validation
            )
          end

          def test_to_openapi_validation
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
