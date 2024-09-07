# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class DefinitionsTest < Minitest::Test
      class FooBarController; end

      def test_inspect
        assert_equal(
          '#<Jsapi::Meta::Definitions ' \
          'owner: Jsapi::Meta::DefinitionsTest::FooBarController, ' \
          'operations: {}, ' \
          'parameters: {}, ' \
          'request_bodies: {}, ' \
          'responses: {}, ' \
          'schemas: {}, ' \
          'openapi_root: nil, ' \
          'rescue_handlers: []>',
          Definitions.new(FooBarController).inspect
        )
      end

      # Include tests

      def test_include
        foo_definitions = Definitions.new
        foo_definitions.add_schema('Foo')

        bar_definitions = Definitions.new
        bar_definitions.include(foo_definitions)

        assert_predicate(bar_definitions.schema('Foo'), :present?)
      end

      def test_include_self
        definitions = Definitions.new
        definitions.include(definitions)
      end

      # Callbacks tests

      def test_add_on_rescue
        definitions.add_on_rescue(:foo)
        assert_equal(:foo, definitions.on_rescue_callbacks.first)
      end

      # Operations tests

      def test_add_operation
        definitions.add_operation('foo')
        assert(definitions.operations.key?('foo'))
      end

      def test_default_operation_name
        definitions.add_operation
        assert_equal(%w[foo_bar], definitions.operations.keys)
      end

      def test_default_operation_path
        definitions.add_operation
        assert_equal('/foo_bar', definitions.operation.path)
      end

      def test_operation
        assert_nil(definitions.operation(nil))

        definitions.add_operation('foo')
        assert_equal('foo', definitions.operation.name)
        assert_equal('foo', definitions.operation('foo').name)
      end

      # Reusable parameters tests

      def test_add_parameter
        definitions.add_parameter('foo')
        assert(definitions.parameters.key?('foo'))
      end

      def test_parameter
        assert_nil(definitions.parameter(nil))
        assert_nil(definitions.parameter('foo'))

        definitions.add_parameter('foo')
        assert_equal('foo', definitions.parameter('foo').name)
      end

      # Reusable request bodies tests

      def test_add_request_body
        definitions.add_request_body('foo')
        assert(definitions.request_bodies.key?('foo'))
      end

      def test_request_body
        assert_nil(definitions.request_body(nil))
        assert_nil(definitions.request_body('foo'))

        definitions.add_request_body('foo')
        assert_predicate(definitions.request_body('foo'), :present?)
      end

      # Reusable responses tests

      def test_add_response
        definitions.add_response('Foo')
        assert(definitions.responses.key?('Foo'))
      end

      def test_response
        assert_nil(definitions.response(nil))
        assert_nil(definitions.response('Foo'))

        definitions.add_response('Foo')
        assert_predicate(definitions.response('Foo'), :present?)
      end

      # Reusable schemas tests

      def test_add_schema
        definitions.add_schema('Foo')
        assert(definitions.schemas.key?('Foo'))
      end

      def test_schema
        assert_nil(definitions.schema(nil))
        assert_nil(definitions.schema('Foo'))

        definitions.add_schema('Foo')
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      # Rescue handlers tests

      def test_rescue_handler_for
        definitions.add_rescue_handler(Controller::ParametersInvalid, status: 400)
        definitions.add_rescue_handler(StandardError, status: 500)

        error = Controller::ParametersInvalid.new(Model::Base.new({}))
        assert_equal(400, definitions.rescue_handler_for(error).status)

        error = StandardError.new
        assert_equal(500, definitions.rescue_handler_for(error).status)

        error = Exception.new
        assert_nil(definitions.rescue_handler_for(error))
      end

      # JSON Schema document tests

      def test_json_schema_document
        definitions.add_schema('Foo').add_property('bar', type: 'string')
        definitions.add_schema('Bar').add_property('foo', schema: 'Foo')

        # 'Foo'
        assert_equal(
          {
            type: %w[object null],
            properties: {
              'bar' => {
                type: %w[string null]
              }
            },
            required: [],
            definitions: {
              'Bar' => {
                type: %w[object null],
                properties: {
                  'foo' => {
                    '$ref': '#/definitions/Foo'
                  }
                },
                required: []
              }
            }
          },
          definitions.json_schema_document('Foo')
        )

        # 'Bar'
        assert_equal(
          {
            type: %w[object null],
            properties: {
              'foo' => {
                '$ref': '#/definitions/Foo'
              }
            },
            required: [],
            definitions: {
              'Foo' => {
                type: %w[object null],
                properties: {
                  'bar' => {
                    type: %w[string null]
                  }
                },
                required: []
              }
            }
          },
          definitions.json_schema_document('Bar')
        )

        # Others
        assert_nil(definitions.json_schema_document('FooBar'))
      end

      def test_json_schema_document_without_definitions
        definitions.add_schema('Foo').add_property('bar', type: 'string')

        assert_equal(
          {
            type: %w[object null],
            properties: {
              'bar' => {
                type: %w[string null]
              }
            },
            required: []
          },
          definitions.json_schema_document('Foo')
        )
      end

      # OpenAPI document tests

      def test_empty_openapi_document
        %w[2.0 3.0 3.1].each do |version|
          assert_equal({}, definitions.openapi_document(version))
        end
      end

      def test_full_openapi_document
        definitions.openapi_root = { info: { title: 'Foo', version: '1' } }

        operation = definitions.add_operation('operation', path: '/bar', method: 'post')
        operation.add_parameter('parameter', ref: 'parameter')
        operation.request_body = { ref: 'request_body' }
        operation.add_response(200, ref: 'response')
        operation.add_response(400, ref: 'error_response')

        definitions.add_parameter('parameter', type: 'string')
        definitions.add_request_body('request_body', type: 'string')
        definitions.add_response('response', schema: 'response_schema')
        definitions.add_response(
          'error_response',
          type: 'string',
          content_type: 'application/problem+json'
        )
        definitions.add_schema('response_schema')

        # OpenAPI 2.0
        assert_equal(
          {
            swagger: '2.0',
            info: {
              title: 'Foo',
              version: '1'
            },
            consumes: %w[application/json],
            produces: %w[application/json application/problem+json],
            paths: {
              '/bar' => {
                'post' => {
                  operationId: 'operation',
                  consumes: %w[application/json],
                  produces: %w[application/json application/problem+json],
                  parameters: [
                    {
                      '$ref': '#/parameters/parameter'
                    },
                    {
                      name: 'body',
                      in: 'body',
                      required: false,
                      type: 'string'
                    }
                  ],
                  responses: {
                    '200' => {
                      '$ref': '#/responses/response'
                    },
                    '400' => {
                      '$ref': '#/responses/error_response'
                    }
                  }
                }
              }
            },
            definitions: {
              'response_schema' => {
                type: 'object',
                properties: {},
                required: []
              }
            },
            parameters: {
              'parameter' => {
                name: 'parameter',
                in: 'query',
                type: 'string',
                allowEmptyValue: true
              }
            },
            responses: {
              'response' => {
                schema: {
                  '$ref': '#/definitions/response_schema'
                }
              },
              'error_response' => {
                schema: {
                  type: 'string'
                }
              }
            }
          },
          definitions.openapi_document('2.0')
        )
        # OpenAPI 3.0
        assert_equal(
          {
            openapi: '3.0.3',
            info: {
              title: 'Foo',
              version: '1'
            },
            paths: {
              '/bar' => {
                'post' => {
                  operationId: 'operation',
                  parameters: [
                    {
                      '$ref': '#/components/parameters/parameter'
                    }
                  ],
                  request_body: {
                    '$ref': '#/components/requestBodies/request_body'
                  },
                  responses: {
                    '200' => {
                      '$ref': '#/components/responses/response'
                    },
                    '400' => {
                      '$ref': '#/components/responses/error_response'
                    }
                  }
                }
              }
            },
            components: {
              schemas: {
                'response_schema' => {
                  type: 'object',
                  nullable: true,
                  properties: {},
                  required: []
                }
              },
              parameters: {
                'parameter' => {
                  name: 'parameter',
                  in: 'query',
                  schema: {
                    type: 'string',
                    nullable: true
                  },
                  allowEmptyValue: true
                }
              },
              requestBodies: {
                'request_body' => {
                  content: {
                    'application/json' => {
                      schema: {
                        type: 'string',
                        nullable: true
                      }
                    }
                  },
                  required: false
                }
              },
              responses: {
                'response' => {
                  content: {
                    'application/json' => {
                      schema: {
                        '$ref': '#/components/schemas/response_schema'
                      }
                    }
                  }
                },
                'error_response' => {
                  content: {
                    'application/problem+json' => {
                      schema: {
                        type: 'string',
                        nullable: true
                      }
                    }
                  }
                }
              }
            }
          },
          definitions.openapi_document('3.0')
        )
      end

      private

      def definitions
        @definitions ||= Definitions.new(FooBarController)
      end
    end
  end
end
