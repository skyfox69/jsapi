# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        class APIKeyTest < Minitest::Test
          def test_minimal_security_scheme_object
            security_scheme = APIKey.new

            %w[2.0 3.0].each do |version|
              assert_equal(
                { type: 'apiKey' },
                security_scheme.to_openapi(Version.from(version))
              )
            end
          end

          def test_full_security_scheme_object
            security_scheme = APIKey.new(
              name: 'X-API-Key',
              in: 'header',
              description: 'Foo'
            )
            %w[2.0 3.0].each do |version|
              assert_equal(
                {
                  type: 'apiKey',
                  name: 'X-API-Key',
                  in: 'header',
                  description: 'Foo'
                },
                security_scheme.to_openapi(Version.from(version))
              )
            end
          end
        end
      end
    end
  end
end
