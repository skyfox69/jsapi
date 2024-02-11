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

        def test_unsupported_format
          error = assert_raises(ArgumentError) { String.new(format: 'foo') }
          assert_equal("format not supported: 'foo'", error.message)
        end

        def test_max_length
          schema = String.new(max_length: 10)
          assert_equal(10, schema.max_length)
        end

        def test_min_length
          schema = String.new(min_length: 10)
          assert_equal(10, schema.min_length)
        end

        def test_pattern
          schema = String.new(pattern: /$\d{4}-\d{2}-\d{2}^/)
          assert_equal('$\d{4}-\d{2}-\d{2}^', schema.pattern.source)
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
            schema.to_openapi_schema
          )
        end

        def test_minimal_openapi_schema
          schema = String.new(existence: true)
          assert_equal(
            {
              type: 'string'
            },
            schema.to_openapi_schema
          )
        end
      end
    end
  end
end