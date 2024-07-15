# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        class OAuth2Test < Minitest::Test
          def test_minimal_openapi_security_scheme_object
            security_scheme = OAuth2.new

            %w[2.0 3.0].each do |version|
              assert_equal(
                { type: 'oauth2' },
                security_scheme.to_openapi(Version.from(version))
              )
            end
          end

          def test_full_openapi_security_scheme_object
            security_scheme = OAuth2.new(description: 'Foo')
            security_scheme.add_oauth_flow(
              :implicit,
              authorization_url: 'https://foo.bar/api/oauth/dialog'
            )
            security_scheme.add_openapi_extension('foo', 'bar')

            # OpenAPI 2.0
            assert_equal(
              {
                type: 'oauth2',
                description: 'Foo',
                flow: 'implicit',
                authorizationUrl: 'https://foo.bar/api/oauth/dialog',
                scopes: {},
                'x-foo': 'bar'
              },
              security_scheme.to_openapi(Version.from('2.0'))
            )
            # OpenAPI 3.0
            assert_equal(
              {
                type: 'oauth2',
                description: 'Foo',
                flows: {
                  implicit: {
                    authorizationUrl: 'https://foo.bar/api/oauth/dialog',
                    scopes: {}
                  }
                },
                'x-foo': 'bar'
              },
              security_scheme.to_openapi(Version.from('3.0'))
            )
          end
        end
      end
    end
  end
end
