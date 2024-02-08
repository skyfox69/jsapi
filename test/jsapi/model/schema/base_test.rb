# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class BaseTest < Minitest::Test
        def test_invalid_option
          error = assert_raises ArgumentError do
            Base.new(foo: 'bar')
          end
          assert_equal("invalid option: 'foo'", error.message)
        end

        def test_add_validator
          schema = Base.new
          schema.add_validator(Validators::Enum.new(%w[foo bar]))

          assert_predicate(schema.validators, :one?)
        end

        def test_enum
          schema = Base.new(enum: %w[foo bar])
          assert_equal(%w[foo bar], schema.enum)
          assert_predicate(schema.validators, :one?)
        end

        def test_reset_enum
          schema = Base.new(enum: %w[foo bar])
          schema.enum = nil

          assert_nil(schema.enum)
          assert_predicate(schema.validators, :empty?)
        end

        def test_nullable
          schema = Base.new
          assert schema.nullable?
        end

        # Validation tests

        def test_validate_present_positive
          schema = StringSchema.new(type: 'string', existence: true)
          assert(DOM.wrap('foo', schema).valid?)
        end

        def test_validate_present_negative
          schema = StringSchema.new(type: 'string', existence: true)
          assert(DOM.wrap('', schema).invalid?)
        end

        def test_validate_allow_empty_positive
          schema = StringSchema.new(type: 'string', existence: :allow_empty)
          assert(DOM.wrap('', schema).valid?)
        end

        def test_validate_allow_empty_negative
          schema = StringSchema.new(type: 'string', existence: :allow_empty)
          assert(DOM.wrap(nil, schema).invalid?)
        end
      end
    end
  end
end
