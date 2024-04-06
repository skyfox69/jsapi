# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class StringTest < Minitest::Test
        def test_format
          schema = String.new(format: 'date')
          assert_equal('date', schema.format)
        end

        def test_raises_exception_on_unsupported_format
          error = assert_raises(ArgumentError) { String.new(format: 'foo') }
          assert_equal('format not supported: "foo"', error.message)
        end

        def test_max_length
          schema = String.new(max_length: 10)
          max_length = schema.validations['max_length']

          assert_predicate(max_length, :present?)
          assert_equal(10, max_length.value)
        end

        def test_min_length
          schema = String.new(min_length: 10)
          min_length = schema.validations['min_length']

          assert_predicate(min_length, :present?)
          assert_equal(10, min_length.value)
        end

        def test_pattern
          schema = String.new(pattern: /foo/)
          pattern = schema.validations['pattern']

          assert_predicate(pattern, :present?)
          assert_equal('foo', pattern.value.source)
        end

        # JSON Schema tests

        def test_minimal_json_schema
          schema = String.new
          assert_equal(
            {
              type: %w[string null]
            },
            schema.to_json_schema
          )
        end

        def test_json_schema
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

        def test_minimal_openapi_3_0_schema
          schema = String.new
          assert_equal(
            {
              type: 'string',
              nullable: true
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_3_0_schema
          schema = String.new(format: 'date')
          assert_equal(
            {
              type: 'string',
              nullable: true,
              format: 'date'
            },
            schema.to_openapi_schema('3.0')
          )
        end
      end
    end
  end
end
