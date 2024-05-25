# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class RootTest < Minitest::Test
        def test_minimal_openapi_object
          definitions = Definitions.new
          root = Root.new

          # OpenAPI 2.0
          assert_equal(
            { swagger: '2.0' },
            root.to_openapi(Version.from('2.0'), definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            { openapi: '3.0.3' },
            root.to_openapi(Version.from('3.0'), definitions)
          )
          # OpenAPI 3.1
          assert_equal(
            { openapi: '3.1.0' },
            root.to_openapi(Version.from('3.1'), definitions)
          )
        end

        def test_full_openapi_object
          definitions = Definitions.new
          root = Root.new(
            info: {
              title: 'Foo',
              version: '1'
            },
            host: 'https://foo.bar',
            base_path: '/foo',
            schemes: %w[https],
            consumes: %w[application/json],
            produces: %w[application/json],
            servers: [
              {
                url: 'https://foo.bar/foo'
              }
            ],
            tags: [
              {
                name: 'Foo'
              }
            ],
            external_docs: {
              url: 'https://foo.bar/docs'
            }
          )
          root.add_callback('onFoo').add_operation('{$request.query.foo}')
          root.add_link('foo', operation_id: 'foo')
          root.add_security_scheme('http_basic', type: 'basic')
          root.add_security.add_scheme('http_basic')

          # OpenAPI 2.0
          assert_equal(
            {
              swagger: '2.0',
              info: {
                title: 'Foo',
                version: '1'
              },
              host: 'https://foo.bar',
              basePath: '/foo',
              schemes: %w[https],
              consumes: %w[application/json],
              produces: %w[application/json],
              securityDefinitions: {
                'http_basic' => {
                  type: 'basic'
                }
              },
              security: [
                {
                  'http_basic' => []
                }
              ],
              tags: [
                { name: 'Foo' }
              ],
              externalDocs: {
                url: 'https://foo.bar/docs'
              }
            },
            root.to_openapi(Version.from('2.0'), definitions)
          )
          # OpenAPI 3.0
          assert_equal(
            {
              openapi: '3.0.3',
              info: {
                title: 'Foo',
                version: '1'
              },
              servers: [
                {
                  url: 'https://foo.bar/foo'
                }
              ],
              components: {
                callbacks: {
                  'onFoo' => {
                    '{$request.query.foo}' => {
                      'get' => {
                        parameters: [],
                        responses: {}
                      }
                    }
                  }
                },
                links: {
                  'foo' => {
                    operationId: 'foo'
                  }
                },
                securitySchemes: {
                  'http_basic' => {
                    type: 'http',
                    scheme: 'basic'
                  }
                }
              },
              security: [
                {
                  'http_basic' => []
                }
              ],
              tags: [
                {
                  name: 'Foo'
                }
              ],
              externalDocs: {
                url: 'https://foo.bar/docs'
              }
            },
            root.to_openapi(Version.from('3.0'), definitions)
          )
          # OpenAPI 3.1
          assert_equal(
            {
              openapi: '3.1.0',
              info: {
                title: 'Foo',
                version: '1'
              },
              servers: [
                {
                  url: 'https://foo.bar/foo'
                }
              ],
              components: {
                callbacks: {
                  'onFoo' => {
                    '{$request.query.foo}' => {
                      'get' => {
                        parameters: [],
                        responses: {}
                      }
                    }
                  }
                },
                links: {
                  'foo' => {
                    operationId: 'foo'
                  }
                },
                securitySchemes: {
                  'http_basic' => {
                    type: 'http',
                    scheme: 'basic'
                  }
                }
              },
              security: [
                {
                  'http_basic' => []
                }
              ],
              tags: [
                {
                  name: 'Foo'
                }
              ],
              externalDocs: {
                url: 'https://foo.bar/docs'
              }
            },
            root.to_openapi(Version.from('3.1'), definitions)
          )
        end
      end
    end
  end
end
