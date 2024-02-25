# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class DefinitionsTest < Minitest::Test
      class FooBarController; end

      def setup
        @api_definitions = Definitions.new(FooBarController)
      end

      # Operation tests

      def test_add_operation
        @api_definitions.add_operation('my_operation')
        assert(@api_definitions.operations.key?('my_operation'))
      end

      def test_add_operation_on_double
        @api_definitions.add_operation('my_operation')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_operation('my_operation')
        end
        assert_equal("operation already defined: 'my_operation'", error.message)
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
        @api_definitions.add_operation('my_operation')
        assert_equal('my_operation', @api_definitions.operation('my_operation').name)
      end

      def test_get_default_operation
        @api_definitions.add_operation('my_operation')
        assert_equal('my_operation', @api_definitions.operation.name)
      end

      def test_get_operation_on_nil
        assert_nil(@api_definitions.operation(nil))
      end

      # Parameter tests

      def test_add_parameter
        @api_definitions.add_parameter('my_parameter')
        assert(@api_definitions.parameters.key?('my_parameter'))
      end

      def test_add_parameter_on_double
        @api_definitions.add_parameter('my_parameter')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_parameter('my_parameter')
        end
        assert_equal("parameter already defined: 'my_parameter'", error.message)
      end

      def test_get_parameter
        @api_definitions.add_parameter('my_parameter')
        assert_equal('my_parameter', @api_definitions.parameter('my_parameter').name)
      end

      def test_get_parameter_on_undefined_name
        assert_nil(@api_definitions.parameter('my_parameter'))
      end

      def test_get_parameter_on_nil
        assert_nil(@api_definitions.parameter(nil))
      end

      # Schema tests

      def test_add_schema
        @api_definitions.add_schema('my_schema')
        assert(@api_definitions.schemas.key?('my_schema'))
      end

      def test_add_schema_on_double
        @api_definitions.add_schema('my_schema')

        error = assert_raises(RuntimeError) do
          @api_definitions.add_schema('my_schema')
        end
        assert_equal("schema already defined: 'my_schema'", error.message)
      end

      def test_get_schema
        @api_definitions.add_schema('my_schema')
        assert_predicate(@api_definitions.schema('my_schema'), :present?)
      end

      def test_get_schema_on_undefined_name
        assert_nil(@api_definitions.schema('my_schema'))
      end

      def test_get_schema_on_nil
        assert_nil(@api_definitions.schema(nil))
      end

      # OpenAPI document tests

      def test_openapi_2_0_document
        @api_definitions.add_operation('my_operation', path: '/foo')
        @api_definitions.add_parameter('my_parameter', type: 'string')
        @api_definitions.add_schema('my_schema')

        assert_equal(
          {
            swagger: '2.0',
            paths: {
              '/foo' => {
                'get' => {
                  operationId: 'my_operation',
                  parameters: [],
                  responses: {}
                }
              }
            },
            parameters: {
              'my_parameter' => {
                name: 'my_parameter',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            },
            definitions: {
              'my_schema' => {
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
        @api_definitions.add_operation('my_operation', path: '/foo')
        @api_definitions.add_parameter('my_parameter', type: 'string')
        @api_definitions.add_schema('my_schema')

        assert_equal(
          {
            openapi: '3.0.3',
            paths: {
              '/foo' => {
                'get' => {
                  operationId: 'my_operation',
                  parameters: [],
                  responses: {}
                }
              }
            },
            components: {
              parameters: {
                'my_parameter' => {
                  name: 'my_parameter',
                  in: 'query',
                  schema: {
                    type: 'string',
                    nullable: true
                  },
                  allowEmptyValue: true
                }
              },
              schemas: {
                'my_schema' => {
                  type: 'object',
                  nullable: true,
                  properties: {},
                  required: []
                }
              }
            }
          },
          @api_definitions.openapi_document('3.0.3')
        )
      end

      def test_minimal_openapi_3_0_document
        assert_equal(
          { openapi: '3.0.3' },
          @api_definitions.openapi_document('3.0.3')
        )
      end

      # OpenAPI root tests

      def test_openapi_root_on_2_0
        assert_equal(
          { swagger: '2.0' },
          @api_definitions.openapi_root('2.0').to_h
        )
      end

      def test_openapi_root_on_3_0_3
        assert_equal(
          { openapi: '3.0.3' },
          @api_definitions.openapi_root('3.0.3').to_h
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
