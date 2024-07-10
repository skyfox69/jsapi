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
          schema = definitions.add_schema('Foo')
          schema.add_property('foo', read_only: true)

          schema = Object.new
          schema.add_all_of(ref: 'Foo')
          schema.add_property('bar', write_only: true)

          properties = schema.resolve_properties(nil, definitions)
          assert_equal(%w[foo bar], properties.keys)

          properties = schema.resolve_properties(:read, definitions)
          assert_equal(%w[foo], properties.keys)

          properties = schema.resolve_properties(:write, definitions)
          assert_equal(%w[bar], properties.keys)
        end

        def test_resolve_properties_raises_an_exception_on_circular_reference
          definitions.add_schema('Foo').add_all_of(ref: 'Bar')
          definitions.add_schema('Bar').add_all_of(ref: 'Foo')

          schema = Object.new
          schema.add_all_of(ref: 'Foo')

          error = assert_raises(RuntimeError) do
            schema.resolve_properties(nil, definitions)
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

        def test_full_json_schema_object
          schema = Object.new(
            all_of: [{ ref: 'Foo' }],
            additional_properties: { type: 'string' }
          )
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
              additionalProperties: {
                type: %w[string null]
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
            additional_properties: { type: 'string' }
          )
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'integer', existence: false)

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

        private

        def definitions
          @definitions ||= Definitions.new
        end
      end
    end
  end
end
