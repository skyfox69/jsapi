# frozen_string_literal: true

module Jsapi
  module Meta
    module SecurityScheme
      module HTTP
        # Specifies a security scheme based on \HTTP basic authentication.
        class Basic < Base
          include OpenAPI::Extensions

          # Returns a hash representing the \OpenAPI security scheme object.
          def to_openapi(version, *)
            version = OpenAPI::Version.from(version)

            with_openapi_extensions(
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
              end
            )
          end
        end
      end
    end
  end
end
