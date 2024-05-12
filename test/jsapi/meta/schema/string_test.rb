# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class StringTest < Minitest::Test
        def test_max_length
          schema = String.new(max_length: 10)
          assert_equal(10, schema.max_length)

          validation = schema.validations['max_length']
          assert_predicate(validation, :present?)
          assert_equal(10, validation.value)
        end

        def test_min_length
          schema = String.new(min_length: 10)
          assert_equal(10, schema.min_length)

          validation = schema.validations['min_length']
          assert_predicate(validation, :present?)
          assert_equal(10, validation.value)
        end

        def test_pattern
          schema = String.new(pattern: /foo/)
          assert_equal(/foo/, schema.pattern)

          validation = schema.validations['pattern']
          assert_predicate(validation, :present?)
          assert_equal('foo', validation.value.source)
        end

        # JSON Schema tests

        def test_minimal_json_schema_object
          schema = String.new
          assert_equal(
            {
              type: %w[string null]
            },
            schema.to_json_schema
          )
        end

        def test_json_schema_object
          schema = String.new(format: 'date')
          assert_equal(
            {
              type: %w[string null],
              format: 'date'
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_minimal_openapi_schema_object
          schema = String.new
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'string',
              nullable: true
            },
            schema.to_openapi('3.0')
          )
          # OpenAPI 3.1
          assert_equal(
            {
              type: %w[string null]
            },
            schema.to_openapi('3.1')
          )
        end

        def test_openapi_schema_object
          schema = String.new(format: 'date')
          assert_equal(
            {
              type: 'string',
              nullable: true,
              format: 'date'
            },
            schema.to_openapi('3.0')
          )
        end
      end
    end
  end
end
