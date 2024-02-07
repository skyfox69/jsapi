# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ParameterTest < Minitest::Test
      def test_openapi_parameters
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
          parameter.to_openapi_parameters
        )
      end

      def test_openapi_parameters_on_query_object
        parameter = Parameter.new('my_parameter', type: 'object', in: 'query')
        parameter.schema.add_property('property1', type: 'string', required: true)
        parameter.schema.add_property('property2', type: 'integer')

        assert_equal(
          [
            {
              name: 'my_parameter[property1]',
              in: 'query',
              required: true,
              schema: {
                type: 'string'
              }
            },
            {
              name: 'my_parameter[property2]',
              in: 'query',
              required: false,
              schema: {
                type: 'integer',
                nullable: true
              }
            }
          ],
          parameter.to_openapi_parameters
        )
      end
    end
  end
end
