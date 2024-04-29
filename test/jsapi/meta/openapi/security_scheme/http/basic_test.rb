# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        module HTTP
          class BasicTest < Minitest::Test
            def test_minimal_security_scheme_object
              security_scheme = Basic.new

              # OpenAPI 2.0
              assert_equal(
                { type: 'basic' },
                security_scheme.to_openapi(Version.from('2.0'))
              )
              # OpenAPI 3.0
              assert_equal(
                {
                  type: 'http',
                  scheme: 'basic'
                },
                security_scheme.to_openapi(Version.from('3.0'))
              )
            end

            def test_full_security_scheme_object
              security_scheme = Basic.new(description: 'Foo')

              # OpenAPI 2.0
              assert_equal(
                {
                  type: 'basic',
                  description: 'Foo'
                },
                security_scheme.to_openapi(Version.from('2.0'))
              )
              # OpenAPI 3.0
              assert_equal(
                {
                  type: 'http',
                  scheme: 'basic',
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
