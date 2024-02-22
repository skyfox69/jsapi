# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class BaseTest < Minitest::Test
        def test_raises_error_on_invalid_option
          error = assert_raises(ArgumentError) { Base.new(foo: 'bar') }
          assert_equal("invalid option: 'foo'", error.message)
        end

        def test_enum
          schema = Base.new(enum: %w[foo bar])
          assert_equal(%w[foo bar], schema.enum)
          assert_predicate(schema.validators, :one?)
        end

        def test_raises_error_on_double_enum
          schema = Base.new(enum: %w[foo bar])

          error = assert_raises { schema.enum = %w[foo bar] }
          assert_equal('enum already defined', error.message)
        end

        def test_existence
          schema = Base.new
          schema.existence = true
          assert_equal(Existence::PRESENT, schema.existence)
        end

        def test_default_existence
          schema = Base.new
          assert_equal(Existence::ALLOW_OMITTED, schema.existence)
        end

        def test_nullable
          schema = Base.new
          assert schema.nullable?
        end
      end
    end
  end
end
