# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ObjectTest < Minitest::Test
        def test_properties
          api_definitions = Definitions.new

          base_schema = api_definitions.add_schema('base_schema')
          base_schema.add_property('foo', type: 'string')

          schema = Object.new
          schema.add_all_of('base_schema')
          schema.add_property('bar', type: 'integer')

          properties = schema.properties(api_definitions)
          assert_equal(%w[foo bar], properties.keys)
        end

        # JSON Schema tests

        def test_json_schema
          schema = Object.new
          schema.add_all_of('Foo')
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'integer', existence: false)

          assert_equal(
            {
              type: %w[object null],
              allOf: [
                { '$ref': '#/definitions/Foo' }
              ],
              properties: {
                'foo' => {
                  type: 'string'
                },
                'bar' => {
                  type: %w[integer null]
                }
              },
              required: %w[foo]
            },
            schema.to_json_schema
          )
        end

        def test_minimal_json_schema
          schema = Object.new(existence: true)
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_json_schema
          )
        end

        # OpenAPI tests

        def test_openapi_schema
          schema = Object.new
          schema.add_all_of('Foo')
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'integer', existence: false)

          assert_equal(
            {
              type: 'object',
              nullable: true,
              allOf: [
                { '$ref': '#/components/schemas/Foo' }
              ],
              properties: {
                'foo' => {
                  type: 'string'
                },
                'bar' => {
                  type: 'integer',
                  nullable: true
                }
              },
              required: %w[foo]
            },
            schema.to_openapi_schema
          )
        end

        def test_minimal_openapi_schema
          schema = Object.new(existence: true)
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi_schema
          )
        end
      end
    end
  end
end
