# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module SecurityScheme
      module HTTP
        class BearerTest < Minitest::Test
          def test_minimal_openapi_security_scheme_object
            security_scheme = Bearer.new

            # OpenAPI 2.0
            assert_nil(
              security_scheme.to_openapi('2.0')
            )
            # OpenAPI 3.0
            assert_equal(
              {
                type: 'http',
                scheme: 'bearer'
              },
              security_scheme.to_openapi('3.0')
            )
          end

          def test_full_openapi_security_scheme_object
            security_scheme = Bearer.new(
              bearer_format: 'JWT',
              description: 'Foo',
              openapi_extensions: { 'foo' => 'bar' }
            )
            # OpenAPI 2.0
            assert_nil(
              security_scheme.to_openapi('2.0')
            )
            # OpenAPI 3.0
            assert_equal(
              {
                type: 'http',
                scheme: 'bearer',
                bearerFormat: 'JWT',
                description: 'Foo',
                'x-foo': 'bar'
              },
              security_scheme.to_openapi('3.0')
            )
          end
        end
      end
    end
  end
end
