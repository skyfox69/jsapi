# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class OAuthFlowTest < Minitest::Test
      def test_minimal_openapi_oauth_flow_object
        %w[2.0 3.0].each do |version|
          assert_equal({ scopes: {} }, OAuthFlow.new.to_openapi(version))
        end
      end

      def test_full_openapi_oauth_flow_object
        oauth_flow = OAuthFlow.new(
          authorization_url: 'https://foo.bar/api/oauth/dialog',
          token_url: 'https://foo.bar/api/oauth/token',
          refresh_url: 'https://foo.bar/api/oauth/refresh',
          scopes: {
            'read:foo' => nil,
            'write:foo' => { description: 'Description of write:foo' }
          },
          openapi_extensions: { 'foo' => 'bar' }
        )
        openapi = {
          authorizationUrl: 'https://foo.bar/api/oauth/dialog',
          tokenUrl: 'https://foo.bar/api/oauth/token',
          refreshUrl: 'https://foo.bar/api/oauth/refresh',
          scopes: {
            'read:foo' => '',
            'write:foo' => 'Description of write:foo'
          },
          'x-foo': 'bar'
        }
        assert_equal(openapi.except(:refreshUrl), oauth_flow.to_openapi('2.0'))
        assert_equal(openapi, oauth_flow.to_openapi('3.0'))
      end
    end
  end
end
