# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      class ObjectTest < Minitest::Test
        def test_add_all_on_nil
          schema = Object.new
          schema.add_all_of(nil)
          assert_predicate(schema.all_of, :empty?)
        end

        def test_properties
          schema = Object.new
          schema.add_property('foo')
          schema.add_property('bar')

          properties = schema.properties(Definitions.new)
          assert_equal(%w[foo bar], properties.keys)
        end

        def test_properties_on_references
          definitions = Definitions.new
          definitions.add_schema('Foo').add_property('foo')
          definitions.add_schema('Bar').add_property('bar')

          schema = Object.new
          schema.add_all_of('Foo')
          schema.add_all_of('Bar')
          schema.add_property('my_property')

          properties = schema.properties(definitions)
          assert_equal(%w[foo bar my_property], properties.keys)
        end

        def test_properties_raises_an_error_on_circular_reference
          definitions = Definitions.new
          definitions.add_schema('Foo').add_all_of('Bar')
          definitions.add_schema('Bar').add_all_of('Foo')

          schema = Object.new
          schema.add_all_of('Foo')

          error = assert_raises(RuntimeError) { schema.properties(definitions) }
          assert_equal('circular reference: Foo', error.message)
        end

        # JSON Schema tests

        def test_json_schema
          definitions = Definitions.new
          definitions.add_schema('Foo')

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
              required: %w[foo],
              definitions: {
                'Foo' => {
                  type: %w[object null],
                  properties: {},
                  required: []
                }
              }
            },
            schema.to_json_schema(definitions)
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

        def test_openapi_schema_2_0
          schema = Object.new
          schema.add_all_of('Foo')
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'integer', existence: false)

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
        end

        def test_minimal_openapi_schema_2_0
          schema = Object.new(existence: true)
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi_schema('2.0')
          )
        end

        def test_openapi_schema_3_0
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
            schema.to_openapi_schema('3.0.3')
          )
        end

        def test_minimal_openapi_schema_3_0
          schema = Object.new(existence: true)
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi_schema('3.0.3')
          )
        end
      end
    end
  end
end
