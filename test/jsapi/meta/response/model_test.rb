# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Response
      class ModelTest < Minitest::Test
        def test_type
          response_model = Model.new(type: 'string')
          assert_equal('string', response_model.type)
        end

        def test_example
          response_model = Model.new(type: 'string', example: 'foo')
          assert_equal('foo', response_model.example.value)
        end

        def test_schema
          response_model = Model.new(schema: 'bar')
          assert_equal('bar', response_model.schema.ref)
        end

        # OpenAPI tests

        def test_minimal_openapi_response_object
          response_model = Model.new(type: 'string', existence: true)

          # OpenAPI 2.0
          assert_equal(
            {
              schema: {
                type: 'string'
              }
            },
            response_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string'
                  }
                }
              }
            },
            response_model.to_openapi('3.0', Definitions.new)
          )
        end

        def test_full_openapi_response_object
          response_model = Model.new(
            type: 'string',
            existence: false,
            example: 'foo'
          )
          response_model.add_header('X-Foo', type: 'string')
          response_model.add_header('X-Bar', ref: 'X-Bar')
          response_model.add_link('foo', operation_id: 'foo')
          response_model.add_openapi_extension('foo', 'bar')

          # OpenAPI 2.0
          assert_equal(
            {
              schema: {
                type: 'string'
              },
              headers: {
                'X-Foo' => {
                  type: 'string'
                }
              },
              examples: {
                'application/json' => 'foo'
              },
              'x-foo': 'bar'
            },
            response_model.to_openapi('2.0', Definitions.new)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string',
                    nullable: true
                  },
                  examples: {
                    'default' => {
                      value: 'foo'
                    }
                  }
                }
              },
              headers: {
                'X-Foo' => {
                  schema: {
                    type: 'string',
                    nullable: true
                  }
                },
                'X-Bar' => {
                  '$ref': '#/components/headers/X-Bar'
                }
              },
              links: {
                'foo' => {
                  operationId: 'foo'
                }
              },
              'x-foo': 'bar'
            },
            response_model.to_openapi('3.0', Definitions.new)
          )
        end
      end
    end
  end
end
