# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module RequestBody
      class BaseTest < Minitest::Test
        def test_type
          request_body = Base.new(type: 'string')
          assert_equal('string', request_body.type)
        end

        def test_example
          request_body = Base.new(type: 'string', example: 'foo')
          assert_equal('foo', request_body.example.value)
        end

        def test_schema
          request_body = Base.new(schema: 'bar')
          assert_equal('bar', request_body.schema.ref)
        end

        # Predicate methods

        def test_required_predicate
          request_body = Base.new(type: 'string', existence: true)
          assert(request_body.required?)

          request_body = Base.new(type: 'string', existence: false)
          assert(!request_body.required?)
        end

        # OpenAPI objects

        def test_minimal_openapi_parameter_object
          request_body = Base.new(type: 'string', existence: true)

          assert_equal(
            {
              name: 'body',
              in: 'body',
              required: true,
              type: 'string'
            },
            request_body.to_openapi_parameter
          )
        end

        def test_full_openapi_parameter_object
          request_body = Base.new(
            type: 'string',
            description: 'Foo',
            openapi_extensions: { 'foo' => 'bar' }
          )
          assert_equal(
            {
              name: 'body',
              in: 'body',
              description: 'Foo',
              required: false,
              type: 'string',
              'x-foo': 'bar'
            },
            request_body.to_openapi_parameter
          )
        end

        def test_minimal_openapi_request_body_object
          request_body = Base.new(type: 'string', existence: true)

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
            request_body.to_openapi('3.0')
          )
        end

        def test_full_openapi_request_body_object
          request_body = Base.new(
            content_type: 'application/foo',
            type: 'string',
            description: 'Foo',
            example: 'foo',
            openapi_extensions: { 'foo' => 'bar' }
          )
          assert_equal(
            {
              description: 'Foo',
              content: {
                'application/foo' => {
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
              required: false,
              'x-foo': 'bar'
            },
            request_body.to_openapi('3.0')
          )
        end
      end
    end
  end
end
