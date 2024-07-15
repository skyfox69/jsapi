# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class OAuthFlowTest < Minitest::Test
        def test_minimal_openapi_oauth_flow_object
          %w[2.0 3.0].each do |version|
            assert_equal({ scopes: {} }, OAuthFlow.new.to_openapi(Version.from(version)))
          end
        end

        def test_full_openapi_oauth_flow_object
          oauth_flow = OAuthFlow.new(
            authorization_url: 'https://foo.bar/api/oauth/dialog',
            token_url: 'https://foo.bar/api/oauth/token',
            refresh_url: 'https://foo.bar/api/oauth/refresh'
          )
          oauth_flow.add_scope('read:foo')
          oauth_flow.add_scope('write:foo', description: 'Description of write:foo')
          oauth_flow.add_openapi_extension('foo', 'bar')

          hash = {
            authorizationUrl: 'https://foo.bar/api/oauth/dialog',
            tokenUrl: 'https://foo.bar/api/oauth/token',
            refreshUrl: 'https://foo.bar/api/oauth/refresh',
            scopes: {
              'read:foo' => '',
              'write:foo' => 'Description of write:foo'
            },
            'x-foo': 'bar'
          }
          assert_equal(hash.except(:refreshUrl), oauth_flow.to_openapi(Version.from('2.0')))
          assert_equal(hash, oauth_flow.to_openapi(Version.from('3.0')))
        end
      end
    end
  end
end
