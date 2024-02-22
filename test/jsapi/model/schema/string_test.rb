# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class StringTest < Minitest::Test
        def test_format
          schema = String.new(format: 'date')
          assert_equal('date', schema.format)
        end

        def test_raises_error_on_unsupported_format
          error = assert_raises(ArgumentError) { String.new(format: 'foo') }
          assert_equal("format not supported: 'foo'", error.message)
        end

        def test_raises_error_on_double_format
          schema = String.new(format: 'date')
          error = assert_raises { schema.format = 'date-time' }
          assert_equal('format already defined', error.message)
        end

        def test_max_length
          schema = String.new(max_length: 10)
          assert_equal(10, schema.max_length)
        end

        def test_raises_error_on_double_max_length
          schema = String.new(max_length: 10)
          error = assert_raises { schema.max_length = 5 }
          assert_equal('max_length already defined', error.message)
        end

        def test_min_length
          schema = String.new(min_length: 10)
          assert_equal(10, schema.min_length)
        end

        def test_raises_error_on_double_min_length
          schema = String.new(min_length: 10)
          error = assert_raises { schema.min_length = 5 }
          assert_equal('min_length already defined', error.message)
        end

        def test_pattern
          schema = String.new(pattern: /foo/)
          assert_equal('foo', schema.pattern.source)
        end

        def test_raises_error_on_double_pattern
          schema = String.new(pattern: /foo/)
          error = assert_raises { schema.pattern = /bar/ }
          assert_equal('pattern already defined', error.message)
        end

        # JSON Schema tests

        def test_json_schema
          schema = String.new(
            existence: false,
            format: 'date',
            min_length: 10,
            max_length: 10,
            pattern: /$\d{4}-\d{2}-\d{2}^/
          )
          assert_equal(
            {
              type: %w[string null],
              format: 'date',
              minLength: 10,
              maxLength: 10,
              pattern: '$\d{4}-\d{2}-\d{2}^'
            },
            schema.to_json_schema
          )
        end

        def test_minimal_json_schema
          schema = String.new(existence: true)
          assert_equal(
            {
              type: 'string'
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema
          schema = String.new(
            existence: false,
            format: 'date',
            min_length: 10,
            max_length: 10,
            pattern: /$\d{4}-\d{2}-\d{2}^/
          )
          assert_equal(
            {
              type: 'string',
              nullable: true,
              format: 'date',
              minLength: 10,
              maxLength: 10,
              pattern: '$\d{4}-\d{2}-\d{2}^'
            },
            schema.to_openapi_schema('3.0.3')
          )
        end

        def test_minimal_openapi_schema
          schema = String.new(existence: true)
          assert_equal(
            {
              type: 'string'
            },
            schema.to_openapi_schema('3.0.3')
          )
        end
      end
    end
  end
end
