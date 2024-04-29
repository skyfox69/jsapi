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

        def test_raises_exception_on_blank_parameter_name
          error = assert_raises(ArgumentError) { Base.new('') }
          assert_equal("parameter name can't be blank", error.message)
        end

        # Predicate methods tests

        def test_required_predicate
          parameter = Base.new('foo', existence: true)
          assert(parameter.required?)

          parameter = Base.new('foo', in: 'path')
          assert(parameter.required?)

          parameter = Base.new('foo', existence: false)
          assert(!parameter.required?)
        end

        # OpenAPI tests

        def test_minimal_openapi_parameter_object_on_query_parameter
          parameter = Base.new('foo', type: 'string', in: 'query')

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_path_segment
          parameter = Base.new('foo', type: 'string', in: 'path')

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_array
          parameter = Base.new('foo', type: 'array', items: { type: 'string' })

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_parameters
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'string')

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_nested_array_parameter
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'array', items: { type: 'string' })

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_minimal_openapi_parameter_object_on_deeply_nested_parameters
          parameter = Base.new('foo', type: 'object', in: 'query')
          property = parameter.schema.add_property('bar', type: 'object')
          property.schema.add_property('foo', type: 'string')

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
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_full_openapi_parameter_object
          parameter = Base.new(
            'foo',
            type: 'string',
            existence: true,
            description: 'Description of foo',
            deprecated: true,
            example: 'bar'
          )

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo',
                in: 'query',
                description: 'Description of foo',
                required: true,
                type: 'string'
              }
            ],
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
                }
              }
            ],
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end

        def test_full_openapi_parameter_object_on_nested_parameters
          parameter = Base.new(
            'foo',
            type: 'object',
            existence: true,
            deprecated: true,
            example: 'bar'
          )
          parameter.schema.add_property(
            'bar',
            type: 'string',
            existence: true,
            description: 'Description of foo'
          )

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                description: 'Description of foo',
                required: true,
                type: 'string'
              }
            ],
            parameter.to_openapi_parameters('2.0', Definitions.new)
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
                  description: 'Description of foo'
                },
                examples: {
                  'default' => {
                    value: 'bar'
                  }
                }
              }
            ],
            parameter.to_openapi_parameters('3.0', Definitions.new)
          )
        end
      end
    end
  end
end
