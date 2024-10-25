# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Parameter
      class BaseTest < Minitest::Test
        def test_name_and_type
          parameter = Base.new('foo', type: 'string')
          assert_equal('foo', parameter.name)
          assert_equal('string', parameter.type)
        end

        def test_example
          parameter = Base.new('foo', type: 'string', example: 'bar')
          assert_equal('bar', parameter.example.value)
        end

        def test_schema
          parameter = Base.new('foo', schema: 'bar')
          assert_equal('bar', parameter.schema.ref)
        end

        def test_raises_exception_on_blank_parameter_name
          error = assert_raises(ArgumentError) { Base.new('') }
          assert_equal("parameter name can't be blank", error.message)
        end

        # Predicate methods

        def test_required_predicate
          parameter = Base.new('foo', existence: true)
          assert(parameter.required?)

          parameter = Base.new('foo', in: 'path')
          assert(parameter.required?)

          parameter = Base.new('foo', existence: false)
          assert(!parameter.required?)
        end

        # OpenAPI objects

        def test_minimal_openapi_parameter_object_on_query_parameter
          definitions = Definitions.new

          parameter = Base.new('foo', type: 'string', in: 'query')

          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo',
              in: 'query',
              type: 'string',
              allowEmptyValue: true
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo',
              in: 'query',
              schema: {
                type: 'string',
                nullable: true
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameter_object_on_path_segment
          definitions = Definitions.new

          parameter = Base.new('foo', type: 'string', in: 'path')

          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo',
              in: 'path',
              required: true,
              type: 'string'
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo',
              in: 'path',
              required: true,
              schema: {
                type: 'string',
                nullable: true
              }
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameter_object_on_array
          definitions = Definitions.new

          parameter = Base.new('foo', type: 'array', items: { type: 'string' })

          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[]',
              in: 'query',
              type: 'array',
              items: {
                type: 'string'
              },
              allowEmptyValue: true,
              collectionFormat: 'multi'
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo[]',
              in: 'query',
              schema: {
                type: 'array',
                nullable: true,
                items: {
                  type: 'string',
                  nullable: true
                }
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_parameters
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'bar' => { type: 'string' }
            }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[bar]',
              in: 'query',
              type: 'string',
              allowEmptyValue: true
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo[bar]',
              in: 'query',
              schema: {
                type: 'string',
                nullable: true
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_array_parameter
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'bar' => {
                type: 'array',
                items: { type: 'string' }
              }
            }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[bar][]',
              in: 'query',
              type: 'array',
              items: {
                type: 'string'
              },
              allowEmptyValue: true,
              collectionFormat: 'multi'
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo[bar][]',
              in: 'query',
              schema: {
                type: 'array',
                nullable: true,
                items: {
                  type: 'string',
                  nullable: true
                }
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameter_object_on_deeply_nested_parameters
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'bar': {
                type: 'object',
                properties: {
                  'foo' => { type: 'string' }
                }
              }
            }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[bar][foo]',
              in: 'query',
              type: 'string',
              allowEmptyValue: true
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo[bar][foo]',
              in: 'query',
              schema: {
                type: 'string',
                nullable: true
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_full_openapi_parameter_object
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            type: 'string',
            existence: true,
            description: 'Lorem ipsum',
            deprecated: true,
            example: 'bar',
            openapi_extensions: { 'foo' => 'bar' }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo',
              in: 'query',
              description: 'Lorem ipsum',
              required: true,
              type: 'string',
              'x-foo': 'bar'
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo',
              in: 'query',
              description: 'Lorem ipsum',
              required: true,
              deprecated: true,
              schema: {
                type: 'string'
              },
              examples: {
                'default' => {
                  value: 'bar'
                }
              },
              'x-foo': 'bar'
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_full_openapi_parameter_object_on_nested_parameters
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            type: 'object',
            properties: {
              'bar' => {
                type: 'string',
                existence: true,
                description: 'Lorem ipsum',
                deprecated: true,
                openapi_extensions: { 'bar' => 'foo' }
              }
            },
            existence: true,
            deprecated: true,
            example: 'bar',
            openapi_extensions: { 'foo' => 'bar' }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[bar]',
              in: 'query',
              description: 'Lorem ipsum',
              required: true,
              type: 'string',
              'x-foo': 'bar',
              'x-bar': 'foo'
            },
            parameter.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo[bar]',
              in: 'query',
              description: 'Lorem ipsum',
              required: true,
              deprecated: true,
              schema: {
                type: 'string',
                description: 'Lorem ipsum',
                'x-bar': 'foo'
              },
              examples: {
                'default' => {
                  value: 'bar'
                }
              },
              'x-foo': 'bar'
            },
            parameter.to_openapi('3.0', definitions)
          )
        end

        def test_openapi_parameter_object_on_read_only_and_write_only_attributes
          parameter = Base.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'read_only_attr' => { type: 'string', read_only: true },
              'write_only_attr' => { type: 'string', write_only: true }
            }
          )
          assert_equal(
            %w[foo[write_only_attr]],
            parameter.to_openapi_parameters('3.0', Definitions.new).map { |p| p[:name] }
          )
        end
      end
    end
  end
end
