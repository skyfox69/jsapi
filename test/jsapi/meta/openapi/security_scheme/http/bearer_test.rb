# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        module HTTP
          class BearerTest < Minitest::Test
            def test_minimal_security_scheme_object
              security_scheme = Bearer.new

              # OpenAPI 2.0
              assert_nil(
                security_scheme.to_openapi(Version.from('2.0'))
              )
              # OpenAPI 3.0
              assert_equal(
                {
                  type: 'http',
                  scheme: 'bearer'
                },
                security_scheme.to_openapi(Version.from('3.0'))
              )
            end

            def test_full_security_scheme_object
              security_scheme = Bearer.new(
                bearer_format: 'JWT',
                description: 'Foo'
              )
              # OpenAPI 2.0
              assert_nil(
                security_scheme.to_openapi(Version.from('2.0'))
              )
              # OpenAPI 3.0
              assert_equal(
                {
                  type: 'http',
                  scheme: 'bearer',
                  bearerFormat: 'JWT',
                  description: 'Foo'
                },
                security_scheme.to_openapi(Version.from('3.0'))
              )
            end
          end
        end
      end
    end
  end
end
