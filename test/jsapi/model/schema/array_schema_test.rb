# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ArraySchemaTest < Minitest::Test
        # JSON Schema tests

        def test_json_schema
          schema = ArraySchema.new(items: { type: 'string' }, nullable: true)
          assert_equal(
            {
              type: %w[array null],
              items: {
                type: 'string'
              }
            },
            schema.to_json_schema
          )
        end

        def test_minimal_json_schema
          schema = ArraySchema.new
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema
          schema = ArraySchema.new(items: { type: 'string' }, nullable: true)
          assert_equal(
            {
              type: 'array',
              nullable: true,
              items: {
                type: 'string'
              }
            },
            schema.to_openapi_schema
          )
        end

        def test_minimal_openapi_schema
          schema = ArraySchema.new
          assert_equal(
            {
              type: 'array',
              items: {}
            },
            schema.to_openapi_schema
          )
        end
      end
    end
  end
end
