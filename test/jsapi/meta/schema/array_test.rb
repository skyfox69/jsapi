# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ArrayTest < Minitest::Test
        def test_max_items
          schema = Array.new(items: { type: 'string' }, max_items: 3)
          assert_equal(3, schema.max_items)

          validation = schema.validations['max_items']
          assert_predicate(validation, :present?)
          assert_equal(3, validation.value)
        end

        def test_min_items
          schema = Array.new(items: { type: 'string' }, min_items: 3)
          assert_equal(3, schema.min_items)

          validation = schema.validations['min_items']
          assert_predicate(validation, :present?)
          assert_equal(3, validation.value)
        end

        # JSON Schema tests

        def test_minimal_json_schema_object
          schema = Array.new(existence: true)
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_json_schema
          )
        end

        def test_json_schema_object
          schema = Array.new(items: { type: 'string' }, existence: false)
          assert_equal(
            {
              type: %w[array null],
              items: {
                type: %w[string null]
              }
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_minimal_openapi_schema_object
          schema = Array.new(existence: true)

          # OpenAPI 2.0
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_openapi_schema('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_schema_object
          schema = Array.new(items: { type: 'string' }, existence: false)

          # OpenAPI 2.0
          assert_equal(
            {
              type: 'array',
              items: {
                type: 'string'
              }
            },
            schema.to_openapi_schema('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'array',
              nullable: true,
              items: {
                type: 'string',
                nullable: true
              }
            },
            schema.to_openapi_schema('3.0')
          )
        end
      end
    end
  end
end
