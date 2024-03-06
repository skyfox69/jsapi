# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class DefinitionsTest < Minitest::Test
      class FooBarController; end

      def setup
        @api_definitions = Definitions.new(FooBarController)
      end

      # Include tests

      def test_include
        foo_definitions = Definitions.new
        foo_definitions.add_schema('Foo')

        bar_definitions = Definitions.new
        bar_definitions.include(foo_definitions)

        assert_predicate(bar_definitions.schema('Foo'), :present?)
      end

      def test_include_self
        definitions = Definitions.new
        definitions.include(definitions)
      end

      # Operation tests

      def test_add_operation
        @api_definitions.add_operation('foo')
        assert(@api_definitions.operations.key?('foo'))
      end

      def test_add_operation_on_double
        @api_definitions.add_operation('foo')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_operation('foo')
        end
        assert_equal("operation already defined: 'foo'", error.message)
      end

      def test_default_operation_name
        @api_definitions.add_operation
        assert_equal(%w[foo_bar], @api_definitions.operations.keys)
      end

      def test_default_operation_path
        @api_definitions.add_operation
        assert_equal('/foo_bar', @api_definitions.operation.path)
      end

      def test_get_operation
        @api_definitions.add_operation('foo')
        assert_equal('foo', @api_definitions.operation('foo').name)
      end

      def test_get_default_operation
        @api_definitions.add_operation('foo')
        assert_equal('foo', @api_definitions.operation.name)
      end

      def test_get_operation_on_nil
        assert_nil(@api_definitions.operation(nil))
      end

      # Parameter tests

      def test_add_parameter
        @api_definitions.add_parameter('foo')
        assert(@api_definitions.parameters.key?('foo'))
      end

      def test_add_parameter_on_double
        @api_definitions.add_parameter('foo')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_parameter('foo')
        end
        assert_equal("parameter already defined: 'foo'", error.message)
      end

      def test_get_parameter
        @api_definitions.add_parameter('foo')
        assert_equal('foo', @api_definitions.parameter('foo').name)
      end

      def test_get_parameter_on_undefined_name
        assert_nil(@api_definitions.parameter('foo'))
      end

      def test_get_parameter_on_nil
        assert_nil(@api_definitions.parameter(nil))
      end

      # Schema tests

      def test_add_schema
        @api_definitions.add_schema('Foo')
        assert(@api_definitions.schemas.key?('Foo'))
      end

      def test_add_schema_on_double
        @api_definitions.add_schema('Foo')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_schema('Foo')
        end
        assert_equal("schema already defined: 'Foo'", error.message)
      end

      def test_get_schema
        @api_definitions.add_schema('Foo')
        assert_predicate(@api_definitions.schema('Foo'), :present?)
      end

      def test_get_schema_on_undefined_name
        assert_nil(@api_definitions.schema('Foo'))
      end

      def test_get_schema_on_nil
        assert_nil(@api_definitions.schema(nil))
      end

      # OpenAPI document tests

      def test_openapi_2_0_document
        @api_definitions.add_operation('operation', path: '/foo')
        @api_definitions.add_parameter('parameter', type: 'string')
        @api_definitions.add_schema('schema')

        assert_equal(
          {
            swagger: '2.0',
            paths: {
              '/foo' => {
                'get' => {
                  operationId: 'operation',
                  parameters: [],
                  responses: {}
                }
              }
            },
            parameters: {
              'parameter' => {
                name: 'parameter',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            },
            definitions: {
              'schema' => {
                type: 'object',
                properties: {},
                required: []
              }
            }
          },
          @api_definitions.openapi_document('2.0')
        )
      end

      def test_minimal_openapi_2_0_document
        assert_equal({ swagger: '2.0' }, @api_definitions.openapi_document('2.0'))
      end

      def test_openapi_3_0_document
        @api_definitions.add_operation('operation', path: '/foo')
        @api_definitions.add_parameter('parameter', type: 'string')
        @api_definitions.add_schema('schema')

        assert_equal(
          {
            openapi: '3.0.3',
            paths: {
              '/foo' => {
                'get' => {
                  operationId: 'operation',
                  parameters: [],
                  responses: {}
                }
              }
            },
            components: {
              parameters: {
                'parameter' => {
                  name: 'parameter',
                  in: 'query',
                  schema: {
                    type: 'string',
                    nullable: true
                  },
                  allowEmptyValue: true
                }
              },
              schemas: {
                'schema' => {
                  type: 'object',
                  nullable: true,
                  properties: {},
                  required: []
                }
              }
            }
          },
          @api_definitions.openapi_document('3.0')
        )
      end

      def test_minimal_openapi_3_0_document
        assert_equal(
          { openapi: '3.0.3' },
          @api_definitions.openapi_document('3.0')
        )
      end

      # OpenAPI root tests

      def test_openapi_root_on_2_0
        assert_equal(
          { swagger: '2.0' },
          @api_definitions.openapi_root('2.0').to_h
        )
      end

      def test_openapi_root_on_3_0
        assert_equal(
          { openapi: '3.0.3' },
          @api_definitions.openapi_root('3.0').to_h
        )
      end

      def test_openapi_root_on_3_1
        assert_equal(
          { openapi: '3.1.0' },
          @api_definitions.openapi_root('3.1').to_h
        )
      end

      def test_openapi_root_on_unsupported_version
        error = assert_raises(ArgumentError) do
          @api_definitions.openapi_root('1.0')
        end
        assert_equal('unsupported OpenAPI version: 1.0', error.message)
      end
    end
  end
end
