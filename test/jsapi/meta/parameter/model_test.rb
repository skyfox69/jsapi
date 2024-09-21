# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Parameter
      class ModelTest < Minitest::Test
        def test_name_and_type
          parameter_model = Model.new('foo', type: 'string')
          assert_equal('foo', parameter_model.name)
          assert_equal('string', parameter_model.type)
        end

        def test_example
          parameter_model = Model.new('foo', type: 'string', example: 'bar')
          assert_equal('bar', parameter_model.example.value)
        end

        def test_schema
          parameter_model = Model.new('foo', schema: 'bar')
          assert_equal('bar', parameter_model.schema.ref)
        end

        def test_raises_exception_on_blank_parameter_name
          error = assert_raises(ArgumentError) { Model.new('') }
          assert_equal("parameter name can't be blank", error.message)
        end

        # Predicate methods

        def test_required_predicate
          parameter_model = Model.new('foo', existence: true)
          assert(parameter_model.required?)

          parameter_model = Model.new('foo', in: 'path')
          assert(parameter_model.required?)

          parameter_model = Model.new('foo', existence: false)
          assert(!parameter_model.required?)
        end

        # OpenAPI objects

        def test_minimal_openapi_parameter_object_on_query_parameter
          parameter_model = Model.new('foo', type: 'string', in: 'query')

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'query',
                schema: {
                  type: 'string',
                  nullable: true
                },
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_path_segment
          parameter_model = Model.new('foo', type: 'string', in: 'path')

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'path',
                required: true,
                type: 'string'
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )

          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'path',
                required: true,
                schema: {
                  type: 'string',
                  nullable: true
                }
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_array
          parameter_model = Model.new('foo', type: 'array', items: { type: 'string' })

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo[]',
                in: 'query',
                type: 'array',
                items: {
                  type: 'string'
                },
                allowEmptyValue: true,
                collectionFormat: 'multi'
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
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
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_parameters
          parameter_model = Model.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'bar' => { type: 'string' }
            }
          )
          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                schema: {
                  type: 'string',
                  nullable: true
                },
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_array_parameter
          parameter_model = Model.new(
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
            [
              {
                name: 'foo[bar][]',
                in: 'query',
                type: 'array',
                items: {
                  type: 'string'
                },
                allowEmptyValue: true,
                collectionFormat: 'multi'
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
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
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_deeply_nested_parameters
          parameter_model = Model.new(
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
            [
              {
                name: 'foo[bar][foo]',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo[bar][foo]',
                in: 'query',
                schema: {
                  type: 'string',
                  nullable: true
                },
                allowEmptyValue: true
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_full_openapi_parameter_object
          parameter_model = Model.new(
            'foo',
            type: 'string',
            existence: true,
            description: 'Description of foo',
            deprecated: true,
            example: 'bar',
            openapi_extensions: { 'foo' => 'bar' }
          )
          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'query',
                description: 'Description of foo',
                required: true,
                type: 'string',
                'x-foo': 'bar'
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'query',
                description: 'Description of foo',
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
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_full_openapi_parameter_object_on_nested_parameters
          parameter_model = Model.new(
            'foo',
            type: 'object',
            properties: {
              'bar' => {
                type: 'string',
                existence: true,
                description: 'Description of foo',
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
            [
              {
                name: 'foo[bar]',
                in: 'query',
                description: 'Description of foo',
                required: true,
                type: 'string',
                'x-foo': 'bar',
                'x-bar': 'foo'
              }
            ],
            parameter_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                description: 'Description of foo',
                required: true,
                deprecated: true,
                schema: {
                  type: 'string',
                  description: 'Description of foo',
                  'x-bar': 'foo'
                },
                examples: {
                  'default' => {
                    value: 'bar'
                  }
                },
                'x-foo': 'bar'
              }
            ],
            parameter_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_openapi_parameter_object_on_read_only_and_write_only_attributes
          parameter_model = Model.new(
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
            parameter_model.to_openapi('3.0', Definitions.new).map { |p| p[:name] }
          )
        end
      end
    end
  end
end
