# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module SecurityScheme
      module HTTP
        class OtherTest < Minitest::Test
          def test_minimal_openapi_security_scheme_object
            security_scheme = Other.new(scheme: 'digest')

            # OpenAPI 2.0
            assert_nil(
              security_scheme.to_openapi('2.0')
            )
            # OpenAPI 3.0
            assert_equal(
              {
                type: 'http',
                scheme: 'digest'
              },
              security_scheme.to_openapi('3.0')
            )
          end

          def test_full_openapi_security_scheme_object
            security_scheme = Other.new(
              scheme: 'digest',
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
                scheme: 'digest',
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
