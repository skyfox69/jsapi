# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Header
      class ModelTest < Minitest::Test
        def test_raises_an_exception_on_object
          error = assert_raises(ArgumentError) do
            Model.new(type: 'object')
          end
          assert_equal("type can't be object", error.message)
        end

        # OpenAPI objects

        def test_minimal_openapi_header_object
          header_model = Model.new(type: 'string')

          # OpenAPI 2.0
          assert_equal(
            { type: 'string' },
            header_model.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              schema: {
                type: 'string',
                nullable: true
              }
            },
            header_model.to_openapi('3.0')
          )
        end

        def test_full_openapi_header_object
          header_model = Model.new(
            type: 'array',
            items: {
              type: 'string'
            },
            collection_format: 'pipes',
            description: 'foo',
            deprecated: true,
            example: 'bar',
            openapi_extensions: { 'foo' => 'bar' }
          )
          # OpenAPI 2.0
          assert_equal(
            {
              type: 'array',
              items: {
                type: 'string'
              },
              collection_format: 'pipes',
              description: 'foo',
              'x-foo': 'bar'
            },
            header_model.to_openapi('2.0')
          )
          # OpenAPI 3.0
          assert_equal(
            {
              schema: {
                type: 'array',
                nullable: true,
                items: {
                  type: 'string',
                  nullable: true
                }
              },
              description: 'foo',
              deprecated: true,
              examples: {
                'default' => {
                  value: 'bar'
                }
              },
              'x-foo': 'bar'
            },
            header_model.to_openapi('3.0')
          )
        end
      end
    end
  end
end
