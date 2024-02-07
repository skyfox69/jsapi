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
          schema = Base.new(nullable: true)
          assert schema.nullable?
        end
      end
    end
  end
end
