# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class DefinitionsTest < Minitest::Test
      class FooBarController; end

      # #include

      def test_include
        foo_definitions = Definitions.new
        foo_definitions.add_schema('Foo')

        bar_definitions = Definitions.new
        bar_definitions.include(foo_definitions)

        schema = bar_definitions.find_component(:schema, 'Foo')
        assert_predicate(schema, :present?)
      end

      def test_include_self
        definitions = Definitions.new
        definitions.include(definitions)
      end

      # Default values

      def test_add_default
        definitions.add_default('array')
        assert(definitions.defaults.key?('array'))
      end

      def test_default_value
        definitions.add_default('array', within_requests: [])

        assert_equal([], definitions.default_value('array', context: :request))

        assert_nil(definitions.default_value(nil))
        assert_nil(definitions.default_value('object'))
      end

      # Operations

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
        assert_equal('/foo_bar', definitions.find_operation.path)
      end

      def test_find_operation
        assert_nil(definitions.find_operation(nil))

        definitions.add_operation('foo')
        assert_equal('foo', definitions.find_operation.name)
        assert_equal('foo', definitions.find_operation('foo').name)
      end

      # Components

      def test_add_parameter
        definitions.add_parameter('foo')
        assert(definitions.parameters.key?('foo'))
      end

      def test_find_component
        assert_nil(definitions.find_component(:parameter, nil))
        assert_nil(definitions.find_component(:parameter, 'foo'))

        definitions.add_parameter('foo')
        assert_equal('foo', definitions.find_component(:parameter, 'foo').name)
      end

      # Rescue handlers

      def test_rescue_handler_for
        definitions.add_rescue_handler(
          error_class: Controller::ParametersInvalid,
          status: 400
        )
        definitions.add_rescue_handler(
          error_class: StandardError,
          status: 500
        )
        error = Controller::ParametersInvalid.new(Model::Base.new({}))
        assert_equal(400, definitions.rescue_handler_for(error).status)

        error = StandardError.new
        assert_equal(500, definitions.rescue_handler_for(error).status)

        error = Exception.new
        assert_nil(definitions.rescue_handler_for(error))
      end

      # JSON Schema documents

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

      # OpenAPI documents

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
