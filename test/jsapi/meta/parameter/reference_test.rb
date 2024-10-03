# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Parameter
      class ReferenceTest < Minitest::Test
        def test_component_type
          assert_equal('parameter', Reference.component_type)
        end

        def test_resolve
          definitions = Definitions.new

          parameter = definitions.add_parameter('foo')
          parameter_reference = Reference.new(ref: 'foo')
          assert_equal(parameter, parameter_reference.resolve(definitions))
        end

        # OpenAPI objects

        def test_openapi_reference_object
          definitions = Definitions.new

          definitions.add_parameter('foo', type: 'string')
          parameter_reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            { '$ref': '#/parameters/foo' },
            parameter_reference.to_openapi('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            { '$ref': '#/components/parameters/foo' },
            parameter_reference.to_openapi('3.0', definitions)
          )
        end

        def test_openapi_reference_object_on_nested_parameters
          definitions = Definitions.new

          parameter = definitions.add_parameter('foo', type: 'object')
          parameter.add_property('bar', type: 'string')

          parameter_reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            {
              name: 'foo[bar]',
              in: 'query',
              type: 'string',
              allowEmptyValue: true
            },
            parameter_reference.to_openapi('2.0', definitions)
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
            parameter_reference.to_openapi('3.0', definitions)
          )
        end
      end
    end
  end
end
