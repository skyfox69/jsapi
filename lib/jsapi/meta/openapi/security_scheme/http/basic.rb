# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        module HTTP
          # Represents a security scheme based on \HTTP basic authentication.
          class Basic < Base
            # Returns a hash representing the security scheme object.
            def to_openapi(version)
              version = OpenAPI::Version.from(version)
              if version.major == 2
                {
                  type: 'basic',
                  description: description
                }
              else
                {
                  type: 'http',
                  scheme: 'basic',
                  description: description
                }
              end.compact
            end
          end
        end
      end
    end
  end
end
