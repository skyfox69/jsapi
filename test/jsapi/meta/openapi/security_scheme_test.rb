# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class SecuritySchemeTest < Minitest::Test
        def test_new_api_key_scheme
          security_scheme = SecurityScheme.new(type: 'api_key')
          assert_kind_of(SecurityScheme::APIKey, security_scheme)
        end

        def test_new_http_basic_scheme
          security_scheme = SecurityScheme.new(type: 'basic')
          assert_kind_of(SecurityScheme::HTTP::Basic, security_scheme)
        end

        def test_new_http_bearer_scheme
          security_scheme = SecurityScheme.new(type: 'http', scheme: 'bearer')
          assert_kind_of(SecurityScheme::HTTP::Bearer, security_scheme)
        end

        def test_new_oauth2_scheme
          security_scheme = SecurityScheme.new(type: 'oauth2')
          assert_kind_of(SecurityScheme::OAuth2, security_scheme)
        end

        def test_new_open_id_connect_scheme
          security_scheme = SecurityScheme.new(type: 'open_id_connect')
          assert_kind_of(SecurityScheme::OpenIDConnect, security_scheme)
        end

        def test_raises_an_exception_on_blank_type
          assert_raises(InvalidArgumentError) do
            SecurityScheme.new(type: nil)
          end
        end

        def test_raises_an_exception_on_invalid_type
          assert_raises(InvalidArgumentError) do
            SecurityScheme.new(type: 'foo')
          end
        end
      end
    end
  end
end
