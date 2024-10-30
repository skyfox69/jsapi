# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Parameter
      class ReferenceTest < Minitest::Test
        # #openapi_parameters

        def test_openapi_parameters
          definitions = Definitions.new(
            parameters: {
              'foo' => { type: 'string' }
            }
          )
          reference = Reference.new(ref: 'foo')

          # OpenAPI 2.0
          assert_equal(
            [
              { '$ref': '#/parameters/foo' }
            ],
            reference.to_openapi_parameters('2.0', definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            [
              { '$ref': '#/components/parameters/foo' }
            ],
            reference.to_openapi_parameters('3.0', definitions)
          )
        end

        def test_openapi_parameters_on_object
          definitions = Definitions.new(
            parameters: {
              'foo' => {
                type: 'object',
                properties: {
                  'bar' => { type: 'string' }
                }
              }
            }
          )
          reference = Reference.new(ref: 'foo')

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
            reference.to_openapi_parameters('2.0', definitions)
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
            reference.to_openapi_parameters('3.0', definitions)
          )
        end
      end
    end
  end
end
