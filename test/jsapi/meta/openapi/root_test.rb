# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class RootTest < Minitest::Test
        def test_add_consumes
          root = Root.new
          root.add_consumes('application/json')
          assert_equal(%w[application/json], root.consumes)
        end

        def test_add_consumes_raises_an_exception_if_argument_is_blank
          root = Root.new
          error = assert_raises(ArgumentError) { root.add_consumes('') }
          assert_equal("mime type can't be blank", error.message)
        end

        def test_add_produces
          root = Root.new
          root.add_produces('application/json')
          assert_equal(%w[application/json], root.produces)
        end

        def test_add_produces_raises_an_exception_if_argument_is_blank
          root = Root.new
          error = assert_raises(ArgumentError) { root.add_produces('') }
          assert_equal("mime type can't be blank", error.message)
        end

        def test_add_scheme
          root = Root.new
          root.add_scheme('https')
          assert_equal(%w[https], root.schemes)
        end

        def test_add_scheme_raises_an_exception_if_scheme_is_invalid
          root = Root.new
          error = assert_raises(ArgumentError) { root.add_scheme('foo') }
          assert_equal('invalid scheme: "foo"', error.message)
        end

        def test_add_security_requirement
          root = Root.new
          security_requirement = root.add_security
          security_requirement.add_scheme('foo')
          assert_equal(
            { 'foo' => [] },
            security_requirement.schemes.transform_values(&:scopes)
          )
          assert(root.security_requirements.first.equal?(security_requirement))
        end

        def test_add_security_scheme
          root = Root.new
          security_scheme = root.add_security_scheme('foo', type: 'apiKey')
          assert_equal('apiKey', security_scheme.type)
          assert(root.security_schemes['foo'].equal?(security_scheme))
        end

        def test_add_security_scheme_raises_an_exception_if_name_is_not_specified
          root = Root.new
          error = assert_raises(ArgumentError) { root.add_security_scheme('') }
          assert_equal("name can't be blank", error.message)
        end

        def test_add_server
          root = Root.new
          server = root.add_server({ url: 'https://foo.bar' })
          assert_equal('https://foo.bar', server.url)
          assert(root.servers.first.equal?(server))
        end

        def test_add_tag
          root = Root.new
          tag = root.add_tag({ name: 'Foo' })
          assert_equal('Foo', tag.name)
          assert(root.tags.first.equal?(tag))
        end

        def test_consumes
          root = Root.new
          root.consumes = 'application/json'
          assert_equal(%w[application/json], root.consumes)

          root.consumes = %w[application/json]
          assert_equal(%w[application/json], root.consumes)
        end

        def test_info
          root = Root.new
          root.info = { title: 'Foo' }
          assert_equal('Foo', root.info.title)
        end

        def test_external_docs
          root = Root.new
          root.external_docs = { url: 'https://foo.bar/docs' }
          assert_equal('https://foo.bar/docs', root.external_docs.url)
        end

        def test_produces
          root = Root.new
          root.produces = 'application/json'
          assert_equal(%w[application/json], root.produces)

          root.produces = %w[application/json]
          assert_equal(%w[application/json], root.produces)
        end

        def test_schemes
          root = Root.new
          root.schemes = 'https'
          assert_equal(%w[https], root.schemes)

          root.schemes = %w[https]
          assert_equal(%w[https], root.schemes)
        end

        def test_schemes_raises_an_exception_if_at_least_one_scheme_is_invalid
          root = Root.new
          error = assert_raises(ArgumentError) do
            root.schemes = %w[http foo bar]
          end
          assert_equal('invalid schemes: "foo", "bar"', error.message)
        end

        def test_minimal_openapi_object
          root = Root.new
          # OpenAPI 2.0
          assert_equal(
            { swagger: '2.0' },
            root.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            { openapi: '3.0.3' },
            root.to_h(Version.from('3.0'))
          )
          # OpenAPI 3.1
          assert_equal(
            { openapi: '3.1.0' },
            root.to_h(Version.from('3.1'))
          )
        end

        def test_full_openapi_object
          root = Root.new(
            info: {
              title: 'Foo',
              version: '1'
            },
            host: 'https://foo.bar',
            base_path: '/foo',
            schemes: 'https',
            consumes: 'application/json',
            produces: 'application/json',
            external_docs: {
              url: 'https://foo.bar/docs'
            }
          )
          root.add_security_scheme('http_basic', type: 'basic')
          root.add_security.add_scheme('http_basic')
          root.add_server(url: 'https://foo.bar/foo')
          root.add_tag(name: 'Foo')

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
                {
                  name: 'Foo'
                }
              ],
              externalDocs: {
                url: 'https://foo.bar/docs'
              }
            },
            root.to_h(Version.from('2.0'))
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
            root.to_h(Version.from('3.0'))
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
            root.to_h(Version.from('3.1'))
          )
        end
      end
    end
  end
end
