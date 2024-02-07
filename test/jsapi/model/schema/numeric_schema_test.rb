# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class NumericSchemaTest < Minitest::Test
        # Validation tests

        def test_exclusive_maximum
          schema = NumericSchema.new(type: 'integer', exclusive_maximum: 0)
          assert_equal(0, schema.exclusive_maximum)
        end

        def test_exclusive_minimum
          schema = NumericSchema.new(type: 'integer', exclusive_minimum: 0)
          assert_equal(0, schema.exclusive_minimum)
        end

        def test_maximum
          schema = NumericSchema.new(type: 'integer', maximum: 0)
          assert_equal(0, schema.maximum)
        end

        def test_minimum
          schema = NumericSchema.new(type: 'integer', minimum: 0)
          assert_equal(0, schema.minimum)
        end

        # JSON Schema tests

        def test_json_schema
          schema = NumericSchema.new(
            type: 'integer',
            nullable: true,
            minimum: 1,
            maximum: 2,
            exclusive_minimum: 0,
            exclusive_maximum: 3
          )
          assert_equal(
            {
              type: %w[integer null],
              minimum: 1,
              maximum: 2,
              exclusiveMinimum: 0,
              exclusiveMaximum: 3
            },
            schema.to_json_schema
          )
        end

        def test_minimal_json_schema
          schema = NumericSchema.new(type: 'integer')
          assert_equal(
            {
              type: 'integer'
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema
          schema = NumericSchema.new(
            type: 'integer',
            nullable: true,
            minimum: 1,
            maximum: 2,
            exclusive_minimum: 0,
            exclusive_maximum: 3
          )
          assert_equal(
            {
              type: 'integer',
              nullable: true,
              minimum: 1,
              maximum: 2,
              exclusiveMinimum: 0,
              exclusiveMaximum: 3
            },
            schema.to_openapi_schema
          )
        end

        def test_minimal_openapi_schema
          schema = NumericSchema.new(type: 'integer')
          assert_equal(
            {
              type: 'integer'
            },
            schema.to_openapi_schema
          )
        end
      end
    end
  end
end
