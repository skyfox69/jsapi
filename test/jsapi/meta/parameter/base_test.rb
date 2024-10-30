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

        def test_minimal_openapi_parameters
          definitions = Definitions.new

          # Query parameter

          parameter = Base.new('foo', type: 'string', in: 'query')

          # OpenAPI 2.0
          expected_openapi_parameter = {
            name: 'foo',
            in: 'query',
            type: 'string',
            allowEmptyValue: true
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('2.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('2.0', definitions)
          )
          # OpenAPI 3.0
          expected_openapi_parameter = {
            name: 'foo',
            in: 'query',
            schema: {
              type: 'string',
              nullable: true
            },
            allowEmptyValue: true
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('3.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('3.0', definitions)
          )

          # Path parameter

          parameter = Base.new('foo', type: 'string', in: 'path')

          # OpenAPI 2.0
          expected_openapi_parameter = {
            name: 'foo',
            in: 'path',
            required: true,
            type: 'string'
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('2.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('2.0', definitions)
          )
          # OpenAPI 3.0
          expected_openapi_parameter = {
            name: 'foo',
            in: 'path',
            required: true,
            schema: {
              type: 'string',
              nullable: true
            }
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('3.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('3.0', definitions)
          )
        end

        def test_minimal_openapi_parameters_on_object
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            in: 'query',
            type: 'object',
            properties: {
              'bar' => { type: 'string' }
            }
          )

          # #to_openapi

          # OpenAPI 2.0
          error = assert_raises(RuntimeError) do
            parameter.to_openapi('2.0', definitions)
          end
          assert_equal(
            "OpenAPI 2.0 doesn't allow object parameters in query",
            error.message
          )
          # OpenAPI 3.0
          assert_equal(
            {
              name: 'foo',
              in: 'query',
              schema: {
                type: 'object',
                nullable: true,
                properties: {
                  'bar' => { type: 'string', nullable: true }
                },
                required: []
              },
              allowEmptyValue: true
            },
            parameter.to_openapi('3.0', definitions)
          )

          # #to_openapi_parameters

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
            parameter.to_openapi_parameters('2.0', definitions)
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
            parameter.to_openapi_parameters('3.0', definitions)
          )
        end

        def test_full_openapi_parameters
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
          expected_openapi_parameter = {
            name: 'foo',
            in: 'query',
            description: 'Lorem ipsum',
            required: true,
            type: 'string',
            'x-foo': 'bar'
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('2.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('2.0', definitions)
          )
          # OpenAPI 3.0
          expected_openapi_parameter = {
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
          }
          assert_equal(
            expected_openapi_parameter,
            parameter.to_openapi('3.0', definitions)
          )
          assert_equal(
            [expected_openapi_parameter],
            parameter.to_openapi_parameters('3.0', definitions)
          )
        end

        def test_full_openapi_parameters_on_object
          definitions = Definitions.new

          parameter = Base.new(
            'foo',
            type: 'object',
            description: 'lorem ipsum',
            existence: true,
            deprecated: true,
            properties: {
              'bar' => {
                type: 'string',
                existence: true,
                description: 'dolor sit amet',
                deprecated: true,
                openapi_extensions: { 'bar' => 'foo' }
              }
            },
            example: { 'bar' => 'consectetur adipisici elit' },
            openapi_extensions: { 'foo' => 'bar' }
          )

          # #to_openapi

          assert_equal(
            {
              name: 'foo',
              in: 'query',
              description: 'lorem ipsum',
              required: true,
              deprecated: true,
              schema: {
                type: 'object',
                properties: {
                  'bar' => {
                    type: 'string',
                    description: 'dolor sit amet',
                    deprecated: true,
                    'x-bar': 'foo'
                  }
                },
                required: %w[bar]
              },
              examples: {
                'default' => {
                  value: { 'bar' => 'consectetur adipisici elit' }
                }
              },
              'x-foo': 'bar'
            },
            parameter.to_openapi('3.0', definitions)
          )

          # #to_openapi_parameters

          # OpenAPI 2.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                description: 'dolor sit amet',
                required: true,
                type: 'string',
                'x-foo': 'bar',
                'x-bar': 'foo'
              }
            ],
            parameter.to_openapi_parameters('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              {
                name: 'foo[bar]',
                in: 'query',
                description: 'dolor sit amet',
                required: true,
                deprecated: true,
                schema: {
                  type: 'string',
                  description: 'dolor sit amet',
                  'x-bar': 'foo'
                },
                'x-foo': 'bar'
              }
            ],
            parameter.to_openapi_parameters('3.0', definitions)
          )
        end

        def test_openapi_parameters_on_directional_properties
          openapi_parameters = Base.new(
            'foo',
            type: 'object',
            properties: {
              'inbound' => {
                type: 'string',
                write_only: true
              },
              'outbound' => {
                type: 'string',
                read_only: true
              }
            }
          ).to_openapi_parameters('3.0', Definitions.new)

          assert_equal(%w[foo[inbound]], openapi_parameters.map { |p| p[:name] })
        end

        def test_openapi_parameter_name_on_array
          openapi_parameters = Base.new(
            'foo',
            type: 'array',
            items: { type: 'string' }
          ).to_openapi_parameters('2.0', Definitions.new)

          assert_equal('foo[]', openapi_parameters.first[:name])
        end

        def test_openapi_parameter_name_on_nested_array
          openapi_parameters = Base.new(
            'foo',
            type: 'object',
            properties: {
              'bar' => {
                type: 'array',
                items: { type: 'string' }
              }
            }
          ).to_openapi_parameters('2.0', Definitions.new)

          assert_equal('foo[bar][]', openapi_parameters.first[:name])
        end

        def test_openapi_parameter_name_on_nested_object
          openapi_parameters = Base.new(
            'foo',
            type: 'object',
            properties: {
              'bar': {
                type: 'object',
                properties: {
                  'foo_bar' => { type: 'string' }
                }
              }
            }
          ).to_openapi_parameters('2.0', Definitions.new)

          assert_equal('foo[bar][foo_bar]', openapi_parameters.first[:name])
        end
      end
    end
  end
end
