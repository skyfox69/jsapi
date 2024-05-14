# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module RequestBody
      class ModelTest < Minitest::Test
        def test_type
          request_body_model = Model.new(type: 'string')
          assert_equal('string', request_body_model.type)
        end

        def test_example
          request_body_model = Model.new(type: 'string', example: 'foo')
          assert_equal('foo', request_body_model.example.value)
        end

        # Predicate methods tests

        def test_required_predicate
          request_body_model = Model.new(type: 'string', existence: true)
          assert(request_body_model.required?)

          request_body_model = Model.new(type: 'string', existence: false)
          assert(!request_body_model.required?)
        end

        # OpenAPI tests

        def test_minimal_openapi_parameter_object
          request_body_model = Model.new(type: 'string', existence: true)
          assert_equal(
            {
              name: 'body',
              in: 'body',
              required: true,
              type: 'string'
            },
            request_body_model.to_openapi_parameter
          )
        end

        def test_full_openapi_parameter_object
          request_body_model = Model.new(type: 'string', description: 'Foo')
          assert_equal(
            {
              name: 'body',
              in: 'body',
              description: 'Foo',
              required: false,
              type: 'string'
            },
            request_body_model.to_openapi_parameter
          )
        end

        def test_minimal_openapi_request_body_object
          request_body_model = Model.new(type: 'string', existence: true)
          assert_equal(
            {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string'
                  }
                }
              },
              required: true
            },
            request_body_model.to_openapi('3.0')
          )
        end

        def test_full_openapi_request_body_object
          request_body_model = Model.new(
            type: 'string',
            description: 'Foo',
            example: 'foo'
          )
          assert_equal(
            {
              description: 'Foo',
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
              required: false
            },
            request_body_model.to_openapi('3.0')
          )
        end
      end
    end
  end
end
