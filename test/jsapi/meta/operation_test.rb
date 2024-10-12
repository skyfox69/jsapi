# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class OperationTest < Minitest::Test
      def test_parameters
        operation = Operation.new('foo')
        parameter = operation.add_parameter('bar', type: 'string')
        assert(parameter.equal?(operation.parameter('bar')))
      end

      def test_responses
        operation = Operation.new('foo')
        default_response = operation.add_response(type: 'string')
        not_found_response = operation.add_response(404, type: 'string')

        assert(default_response.equal?(operation.response))
        assert(not_found_response.equal?(operation.response(404)))
      end

      # OpenAPI objects

      def test_minimal_openapi_operation_object
        definitions = Definitions.new
        operation = Operation.new('foo')

        %w[2.0 3.0].each do |version|
          assert_equal(
            {
              operationId: 'foo',
              parameters: [],
              responses: {}
            },
            operation.to_openapi(version, definitions)
          )
        end
      end

      def test_full_openapi_operation_object
        definitions = Definitions.new
        operation = Operation.new(
          'foo',
          tags: %w[Foo],
          summary: 'Summary of foo',
          description: 'Lorem ipsum',
          external_docs: {
            url: 'https://foo.bar/docs'
          },
          parameters: {
            'bar' => {
              type: 'string',
              in: 'query'
            }
          },
          request_body: {
            type: 'string',
            existence: true
          },
          responses: {
            nil => {
              type: 'string'
            }
          },
          callbacks: {
            'onBar' => {
              operations: {
                '{$request.query.bar}' => {}
              }
            }
          },
          security_requirements: {
            schemes: {
              'http_basic' => {}
            }
          },
          deprecated: true,
          schemes: %w[https],
          servers: [
            { url: 'https://foo.bar/foo' }
          ],
          openapi_extensions: { 'foo' => 'bar' }
        )
        # OpenAPI 2.0
        assert_equal(
          {
            operationId: 'foo',
            tags: %w[Foo],
            summary: 'Summary of foo',
            description: 'Lorem ipsum',
            externalDocs: {
              url: 'https://foo.bar/docs'
            },
            consumes: [
              'application/json'
            ],
            produces: [
              'application/json'
            ],
            parameters: [
              {
                name: 'bar',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              },
              {
                name: 'body',
                in: 'body',
                required: true,
                type: 'string'
              }
            ],
            responses: {
              'default' => {
                schema: {
                  type: 'string'
                }
              }
            },
            schemes: %w[https],
            deprecated: true,
            security: [
              { 'http_basic' => [] }
            ],
            'x-foo': 'bar'
          },
          operation.to_openapi('2.0', definitions)
        )
        # OpenAPI 3.0
        assert_equal(
          {
            operationId: 'foo',
            tags: %w[Foo],
            summary: 'Summary of foo',
            description: 'Lorem ipsum',
            externalDocs: {
              url: 'https://foo.bar/docs'
            },
            parameters: [
              {
                name: 'bar',
                in: 'query',
                schema: {
                  type: 'string',
                  nullable: true
                },
                allowEmptyValue: true
              }
            ],
            request_body: {
              content: {
                'application/json' => {
                  schema: {
                    type: 'string'
                  }
                }
              },
              required: true
            },
            responses: {
              'default' => {
                content: {
                  'application/json' => {
                    schema: {
                      type: 'string',
                      nullable: true
                    }
                  }
                }
              }
            },
            callbacks: {
              'onBar' => {
                '{$request.query.bar}' => {
                  'get' => {
                    parameters: [],
                    responses: {}
                  }
                }
              }
            },
            deprecated: true,
            security: [
              { 'http_basic' => [] }
            ],
            servers: [
              { url: 'https://foo.bar/foo' }
            ],
            'x-foo': 'bar'
          },
          operation.to_openapi('3.0', definitions)
        )
      end
    end
  end
end
