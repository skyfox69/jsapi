# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class ObjectTest < Minitest::Test
        def test_add_property
          schema = Object.new
          property = schema.add_property('foo', type: 'string')
          assert(property.equal?(schema.property('foo')))
        end

        # #resolve_properties

        def test_resolve_properties
          definitions = Definitions.new(
            schemas: {
              'Foo' => {
                properties: {
                  'foo' => { read_only: true }
                }
              }
            }
          )
          schema = Object.new(
            all_of: { ref: 'Foo' },
            properties: {
              'bar' => { write_only: true }
            }
          )
          properties = schema.resolve_properties(definitions)
          assert_equal(%w[foo bar], properties.keys)

          properties = schema.resolve_properties(definitions, context: :response)
          assert_equal(%w[foo], properties.keys)

          properties = schema.resolve_properties(definitions, context: :request)
          assert_equal(%w[bar], properties.keys)
        end

        def test_resolve_properties_raises_an_exception_on_circular_reference
          definitions = Definitions.new(
            schemas: {
              'Foo' => {
                all_of: { ref: 'Bar' }
              },
              'Bar' => {
                all_of: { ref: 'Foo' }
              }
            }
          )
          schema = Object.new(all_of: { ref: 'Foo' })

          error = assert_raises(RuntimeError) do
            schema.resolve_properties(definitions)
          end
          assert_equal('circular reference: Foo', error.message)
        end

        # #resolve_schema

        def test_resolve_schema
          definitions = Definitions.new(
            schemas: {
              'Foo' => {},
              'Bar' => {}
            }
          )
          schema = Object.new(
            discriminator: { property_name: 'foo' },
            properties: {
              'foo' => { type: 'string', default: 'Foo' }
            }
          )
          assert_equal(
            definitions.find_component(:schema, 'Foo'),
            schema.resolve_schema({ foo: 'Foo' }, definitions)
          )
          assert_equal(
            definitions.find_component(:schema, 'Bar'),
            schema.resolve_schema({ foo: 'Bar' }, definitions)
          )
          assert_equal(
            definitions.find_component(:schema, 'Foo'),
            schema.resolve_schema({ foo: nil }, definitions)
          )
        end

        def test_resolve_schema_raises_an_exception_on_unknown_discriminator_property
          schema = Object.new(
            discriminator: { property_name: 'foo' },
            properties: {
              'bar' => { type: 'string' }
            }
          )
          error = assert_raises(RuntimeError) do
            schema.resolve_schema({}, Definitions.new)
          end
          assert_equal('discriminator property must be "bar", is "foo"', error.message)
        end

        def test_resolve_schema_raises_an_exception_on_blank_value
          schema = Object.new(
            discriminator: { property_name: 'foo' },
            properties: {
              'foo' => { type: 'string' }
            }
          )
          error = assert_raises(RuntimeError) do
            schema.resolve_schema({}, Definitions.new)
          end
          assert_equal("foo can't be nil", error.message)
        end

        def test_resolve_schema_raises_an_exception_on_missing_inheriting_schema
          schema = Object.new(
            discriminator: { property_name: 'foo' },
            properties: {
              'foo' => { type: 'string' }
            }
          )
          error = assert_raises(RuntimeError) do
            schema.resolve_schema({ foo: 'Bar' }, Definitions.new)
          end
          assert_equal("inheriting schema couldn't be found: \"Bar\"", error.message)
        end

        # JSON Schema objects

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

        def test_full_json_schema_object
          schema = Object.new(
            all_of: [{ ref: 'Foo' }],
            properties: {
              'foo' => {
                type: 'string',
                existence: true
              },
              'bar' => {
                type: 'integer',
                existence: false
              }
            },
            additional_properties: { type: 'string' }
          )
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
              additionalProperties: {
                type: %w[string null]
              },
              required: %w[foo]
            },
            schema.to_json_schema
          )
        end

        # OpenAPI objects

        def test_minimal_openapi_schema_object
          schema = Object.new(existence: true)

          # OpenAPI 2.0
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'object',
              properties: {},
              required: []
            },
            schema.to_openapi('3.0')
          )
        end

        def test_full_openapi_schema_object
          schema = Object.new(
            all_of: [{ ref: 'Foo' }],
            discriminator: { property_name: 'foo' },
            properties: {
              'foo' => {
                type: 'string',
                existence: true
              },
              'bar' => {
                type: 'integer',
                existence: false
              }
            },
            additional_properties: { type: 'string' }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              type: 'object',
              allOf: [
                { '$ref': '#/definitions/Foo' }
              ],
              discriminator: 'foo',
              properties: {
                'foo' => {
                  type: 'string'
                },
                'bar' => {
                  type: 'integer'
                }
              },
              additionalProperties: {
                type: 'string'
              },
              required: %w[foo]
            },
            schema.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'object',
              nullable: true,
              allOf: [
                { '$ref': '#/components/schemas/Foo' }
              ],
              discriminator: {
                propertyName: 'foo'
              },
              properties: {
                'foo' => {
                  type: 'string'
                },
                'bar' => {
                  type: 'integer',
                  nullable: true
                }
              },
              additionalProperties: {
                type: 'string',
                nullable: true
              },
              required: %w[foo]
            },
            schema.to_openapi('3.0')
          )
        end
      end
    end
  end
end
