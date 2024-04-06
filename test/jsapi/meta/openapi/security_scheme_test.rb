# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class SecuritySchemeTest < Minitest::Test
        %i[authorization_code client_credentials implicit password].each do |key|
          define_method "test_add_#{key}_oauth_flow" do
            security_scheme = SecurityScheme.new(type: 'oauth2')
            flow = security_scheme.add_oauth_flow(
              key,
              authorization_url: 'https://foo.bar/api/oauth/dialog'
            )
            key = key.to_s.camelize(:lower).to_sym # e.g. :AuthorizationCode

            assert_equal('https://foo.bar/api/oauth/dialog', flow.authorization_url)
            assert(security_scheme.oauth_flows[key], flow)
          end
        end

        def test_add_oauth_flow_raises_an_exception_if_flow_is_invalid
          security_scheme = SecurityScheme.new(type: 'oauth2')
          error = assert_raises(ArgumentError) do
            security_scheme.add_oauth_flow(nil)
          end
          assert_equal('invalid flow: nil', error.message)
        end

        def test_raises_exception_on_invalid_location
          error = assert_raises(ArgumentError) do
            SecurityScheme.new(type: 'apiKey', in: 'foo')
          end
          assert_equal('invalid location: "foo"', error.message)
        end

        def test_raises_exception_on_invalid_type
          error = assert_raises(ArgumentError) do
            SecurityScheme.new(type: 'foo')
          end
          assert_equal('invalid type: "foo"', error.message)
        end

        def test_api_key_scheme
          security_scheme = SecurityScheme.new(
            type: 'apiKey',
            name: 'X-API-Key',
            in: 'header'
          )
          # OpenAPI 2.0
          assert_equal(
            {
              type: 'apiKey',
              name: 'X-API-Key',
              in: 'header'
            },
            security_scheme.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'apiKey',
              name: 'X-API-Key',
              in: 'header'
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        # Basic auth scheme tests

        def test_basic_auth_scheme
          security_scheme = SecurityScheme.new(type: 'basic')

          # OpenAPI 2.0
          assert_equal(
            { type: 'basic' },
            security_scheme.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            { type: 'http', scheme: 'basic' },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_http_basic_scheme
          security_scheme = SecurityScheme.new(
            type: 'http',
            scheme: 'basic'
          )
          # OpenAPI 2.0
          assert_equal(
            { type: 'basic' },
            security_scheme.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'http',
              scheme: 'basic'
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_minimal_http_bearer_scheme
          security_scheme = SecurityScheme.new(
            type: 'http',
            scheme: 'bearer'
          )
          # OpenAPI 2.0
          assert_nil(security_scheme.to_h(Version.from('2.0')))

          # OpenAPI 3.0
          assert_equal(
            {
              type: 'http',
              scheme: 'bearer'
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_full_http_bearer_scheme
          security_scheme = SecurityScheme.new(
            type: 'http',
            scheme: 'bearer',
            bearer_format: 'JWT'
          )
          # OpenAPI 2.0
          assert_nil(security_scheme.to_h(Version.from('2.0')))

          # OpenAPI 3.0
          assert_equal(
            {
              type: 'http',
              scheme: 'bearer',
              bearerFormat: 'JWT'
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_minimal_oauth_scheme
          security_scheme = SecurityScheme.new(type: 'oauth2')
          # OpenAPI 2.0
          assert_equal(
            { type: 'oauth2' },
            security_scheme.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            { type: 'oauth2' },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_full_oauth_scheme
          security_scheme = SecurityScheme.new(type: 'oauth2')
          security_scheme.add_oauth_flow(
            :implicit,
            authorization_url: 'https://foo.bar/api/oauth/dialog'
          )
          # OpenAPI 2.0
          assert_equal(
            {
              type: 'oauth2',
              flow: 'implicit',
              authorizationUrl: 'https://foo.bar/api/oauth/dialog',
              scopes: {}
            },
            security_scheme.to_h(Version.from('2.0'))
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'oauth2',
              flows: {
                implicit: {
                  authorizationUrl: 'https://foo.bar/api/oauth/dialog',
                  scopes: {}
                }
              }
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_minimal_open_id_connect_scheme
          security_scheme = SecurityScheme.new(type: 'openIdConnect')
          # OpenAPI 2.0
          assert_nil(security_scheme.to_h(Version.from('2.0')))

          # OpenAPI 3.0
          assert_equal(
            { type: 'openIdConnect' },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_full_open_id_connect_scheme
          security_scheme = SecurityScheme.new(
            type: 'openIdConnect',
            open_id_connect_url: 'foo'
          )
          # OpenAPI 3.0
          assert_equal(
            {
              type: 'openIdConnect',
              openIdConnectUrl: 'foo'
            },
            security_scheme.to_h(Version.from('3.0'))
          )
        end

        def test_description
          security_scheme = SecurityScheme.new(
            type: 'apiKey',
            name: 'X-API-Key',
            in: 'header',
            description: 'Description of X-API-Key'
          )
          %w[2.0 3.0].each do |version|
            assert_equal(
              {
                type: 'apiKey',
                name: 'X-API-Key',
                in: 'header',
                description: 'Description of X-API-Key'
              },
              security_scheme.to_h(Version.from(version))
            )
          end
        end

        def test_to_openapi_raises_an_exception_if_type_is_invalid
          security_scheme = SecurityScheme.new
          error = assert_raises(RuntimeError) do
            security_scheme.to_h(Version.from('2.0'))
          end
          assert_equal('invalid type: nil', error.message)
        end
      end
    end
  end
end
