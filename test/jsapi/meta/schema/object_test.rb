# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ObjectTest < Minitest::Test
        def test_properties
          schema = Object.new
          property = schema.add_property('foo', type: 'string')
          assert(property.equal?(schema.property('foo')))
        end

        # resolve_properties tests

        def test_resolve_properties
          definitions = Definitions.new
          definitions.add_schema('Foo').add_property('foo')

          schema = Object.new
          schema.add_all_of(schema: 'Foo')
          schema.add_property('bar')

          properties = schema.resolve_properties(definitions)
          assert_equal(%w[foo bar], properties.keys)
        end

        def test_resolve_properties_raises_an_exception_on_circular_reference
          definitions = Definitions.new
          definitions.add_schema('Foo').add_all_of(schema: 'Bar')
          definitions.add_schema('Bar').add_all_of(schema: 'Foo')

          schema = Object.new
          schema.add_all_of(schema: 'Foo')

          error = assert_raises(RuntimeError) do
            schema.resolve_properties(definitions)
          end
          assert_equal('circular reference: Foo', error.message)
        end

        # JSON Schema tests

        def test_minimal_json_schema_object
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

        def test_json_schema_object
          schema = Object.new(all_of: [{ schema: 'Foo' }])
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

        # OpenAPI tests

        def test_minimal_openapi_schema_object
          schema = Object.new(existence: true)

          # OpenAPI 2.0
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi_schema('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi_schema('3.0')
          )
        end

        def test_openapi_schema_object
          schema = Object.new(all_of: [{ schema: 'Foo' }])
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'integer', existence: false)

          # OpenAPI 2.0
          assert_equal(
            {
              type: 'object',
              allOf: [
                { '$ref': '#/definitions/Foo' }
              ],
              properties: {
                'foo' => {
                  type: 'string'
                },
                'bar' => {
                  type: 'integer'
                }
              },
              required: %w[foo]
            },
            schema.to_openapi_schema('2.0')
          )
          # OpenAPI 3.0
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
            schema.to_openapi_schema('3.0')
          )
        end
      end
    end
  end
end
