# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Parameter
      class BaseTest < Minitest::Test
        def test_raises_error_on_blank_parameter_name
          error = assert_raises(ArgumentError) { Base.new('') }
          assert_equal("parameter name can't be blank", error.message)
        end

        def test_example
          parameter = Base.new('foo', example: 'bar')
          assert_equal('bar', parameter.examples['default'].value)
        end

        def test_required
          parameter = Base.new('foo', existence: true)
          assert(parameter.required?)
        end

        def test_required_on_path_parameter
          parameter = Base.new('foo', in: 'path')
          assert(parameter.required?)
        end

        def test_not_required
          parameter = Base.new('foo', existence: false)
          assert(!parameter.required?)
        end

        # OpenAPI 2.0 tests

        def test_openapi_2_0_path_parameter
          parameter = Base.new('foo', type: 'string', in: 'path')
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
        end

        def test_openapi_2_0_query_parameter
          parameter = Base.new('foo', type: 'string', in: 'query')
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
        end

        def test_openapi_2_0_array_parameter
          parameter = Base.new('foo', type: 'array', items: { type: 'string' })
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
        end

        def test_openapi_2_0_object_parameter
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'string')

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
        end

        def test_openapi_2_0_array_property
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'array', items: { type: 'string' })

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
        end

        def test_openapi_2_0_nested_object_parameter
          parameter = Base.new('foo', type: 'object', in: 'query')
          property = parameter.schema.add_property('bar', type: 'object')
          property.schema.add_property('foo', type: 'string')

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
        end

        # OpenAPI 3.0 tests

        def test_openapi_3_0_path_parameter
          parameter = Base.new('foo', type: 'string', in: 'path')
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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end

        def test_openapi_3_0_query_parameter
          parameter = Base.new('foo', type: 'string', in: 'query')
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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end

        def test_openapi_3_0_array_parameter
          parameter = Base.new('foo', type: 'array', items: { type: 'string' })
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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end

        def test_openapi_3_0_object_parameter
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'string')

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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end

        def test_openapi_3_0_array_property
          parameter = Base.new('foo', type: 'object', in: 'query')
          parameter.schema.add_property('bar', type: 'array', items: { type: 'string' })

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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end

        def test_openapi_3_0_nested_object_parameter
          parameter = Base.new('foo', type: 'object', in: 'query')
          property = parameter.schema.add_property('bar', type: 'object')
          property.schema.add_property('foo', type: 'string')

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
            parameter.to_openapi_parameters('3.0.3', Definitions.new)
          )
        end
      end
    end
  end
end
