# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class OAuthFlowTest < Minitest::Test
        def test_add_scope
          oauth_flow = OAuthFlow.new
          oauth_flow.add_scope('read:foo', description: 'Description of read:foo')
          assert_equal('Description of read:foo', oauth_flow.scopes['read:foo'].description)
        end

        def test_add_scope_raises_an_exception_if_name_is_blank
          oauth_flow = OAuthFlow.new
          error = assert_raises(ArgumentError) do
            oauth_flow.add_scope('')
          end
          assert_equal("name can't be blank", error.message)
        end

        def test_minimal_oauth_flow_object
          %w[2.0 3.0].each do |version|
            assert_equal({ scopes: {} }, OAuthFlow.new.to_h(Version.from(version)))
          end
        end

        def test_oauth_flow_object
          oauth_flow = OAuthFlow.new(
            authorization_url: 'https://foo.bar/api/oauth/dialog',
            token_url: 'https://foo.bar/api/oauth/token',
            refresh_url: 'https://foo.bar/api/oauth/refresh'
          )
          oauth_flow.add_scope('read:foo')
          oauth_flow.add_scope('write:foo', description: 'Description of write:foo')

          hash = {
            authorizationUrl: 'https://foo.bar/api/oauth/dialog',
            tokenUrl: 'https://foo.bar/api/oauth/token',
            refreshUrl: 'https://foo.bar/api/oauth/refresh',
            scopes: {
              'read:foo' => '',
              'write:foo' => 'Description of write:foo'
            }
          }
          assert_equal(hash.except(:refreshUrl), oauth_flow.to_h(Version.from('2.0')))
          assert_equal(hash, oauth_flow.to_h(Version.from('3.0')))
        end
      end
    end
  end
end
