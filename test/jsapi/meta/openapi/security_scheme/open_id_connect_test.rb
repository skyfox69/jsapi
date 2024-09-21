# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        class OpenIDConnectTest < Minitest::Test
          def test_minimal_openapi_security_scheme_object
            security_scheme = OpenIDConnect.new

            # OpenAPI 2.0
            assert_nil(
              security_scheme.to_openapi(Version.from('2.0'))
            )
            # OpenAPI 3.0
            assert_equal(
              { type: 'openIdConnect' },
              security_scheme.to_openapi(Version.from('3.0'))
            )
          end

          def test_full_openapi_security_scheme_object
            security_scheme = OpenIDConnect.new(
              open_id_connect_url: 'https://foo.bar/openid',
              description: 'Foo',
              openapi_extensions: { 'foo' => 'bar' }
            )
            # OpenAPI 2.0
            assert_nil(
              security_scheme.to_openapi(Version.from('2.0'))
            )
            # OpenAPI 3.0
            assert_equal(
              {
                type: 'openIdConnect',
                openIdConnectUrl: 'https://foo.bar/openid',
                description: 'Foo',
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
