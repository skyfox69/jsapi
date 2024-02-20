# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ParameterTest < Minitest::Test
      def test_required
        parameter = Parameter.new('my_parameter', existence: true)
        assert(parameter.required?)
      end

      def test_required_on_path_parameter
        parameter = Parameter.new('my_parameter', in: 'path')
        assert(parameter.required?)
      end

      def test_not_required
        parameter = Parameter.new('my_parameter', existence: false)
        assert(!parameter.required?)
      end

      # OpenAPI parameters tests

      def test_openapi_parameters_2_0
        parameter = Parameter.new('my_parameter', type: 'string', in: 'query')
        assert_equal(
          [
            {
              name: 'my_parameter',
              in: 'query',
              required: false,
              type: 'string'
            }
          ],
          parameter.to_openapi_parameters('2.0')
        )
      end

      def test_openapi_parameters_2_0_on_query_object
        parameter = Parameter.new('my_parameter', type: 'object', in: 'query', existence: true)
        parameter.schema.add_property('property1', type: 'string', existence: true)
        parameter.schema.add_property('property2', type: 'integer')

        assert_equal(
          [
            {
              name: 'my_parameter[property1]',
              in: 'query',
              required: true,
              type: 'string'
            },
            {
              name: 'my_parameter[property2]',
              in: 'query',
              required: false,
              type: 'integer'
            }
          ],
          parameter.to_openapi_parameters('2.0')
        )
      end

      def test_openapi_parameters_3_0
        parameter = Parameter.new('my_parameter', type: 'string', in: 'query')
        assert_equal(
          [
            {
              name: 'my_parameter',
              in: 'query',
              required: false,
              schema: {
                type: 'string',
                nullable: true
              }
            }
          ],
          parameter.to_openapi_parameters('3.0.3')
        )
      end

      def test_openapi_parameters_3_0_on_query_object
        parameter = Parameter.new('my_parameter', type: 'object', in: 'query', existence: true)
        parameter.schema.add_property('property1', type: 'string', existence: true)
        parameter.schema.add_property('property2', type: 'integer')

        assert_equal(
          [
            {
              name: 'my_parameter',
              in: 'query',
              required: true,
              schema: {
                type: 'object',
                properties: {
                  'property1' => {
                    type: 'string'
                  },
                  'property2' => {
                    type: 'integer',
                    nullable: true
                  }
                },
                required: %w[property1]
              },
              explode: true
            }
          ],
          parameter.to_openapi_parameters('3.0.3')
        )
      end
    end
  end
end
