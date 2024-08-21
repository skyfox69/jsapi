# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module Header
        class ModelTest < Minitest::Test
          # OpenAPI tests

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
              type: 'string',
              description: 'foo',
              deprecated: true,
              example: 'bar'
            )
            header_model.add_openapi_extension('foo', 'bar')

            # OpenAPI 2.0
            assert_equal(
              {
                type: 'string',
                description: 'foo',
                'x-foo': 'bar'
              },
              header_model.to_openapi('2.0')
            )
            # OpenAPI 3.0
            assert_equal(
              {
                schema: {
                  type: 'string',
                  nullable: true
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
end