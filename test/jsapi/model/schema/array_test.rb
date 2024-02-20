# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ArrayTest < Minitest::Test
        # JSON Schema tests

        def test_json_schema
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

        def test_minimal_json_schema
          schema = Array.new(existence: true)
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema_2_0
          schema = Array.new(items: { type: 'string' }, existence: false)
          assert_equal(
            {
              type: 'array',
              items: {
                type: 'string'
              }
            },
            schema.to_openapi_schema('2.0')
          )
        end

        def test_minimal_openapi_schema_2_0
          schema = Array.new(existence: false)
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_openapi_schema('2.0')
          )
        end

        def test_openapi_schema_3_0
          schema = Array.new(items: { type: 'string' }, existence: false)
          assert_equal(
            {
              type: 'array',
              nullable: true,
              items: {
                type: 'string',
                nullable: true
              }
            },
            schema.to_openapi_schema('3.0.3')
          )
        end

        def test_minimal_openapi_schema_3_0
          schema = Array.new(existence: true)
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_openapi_schema('3.0.3')
          )
        end
      end
    end
  end
end
