# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        # Represents a security scheme based on \OAuth2.
        class OAuth2 < Base
          include Extensions

          ##
          # :attr: oauth_flows
          # The hash containing the OAuth flows. Possible keys are:
          #
          # - <code>"authorization_code"</code>
          # - <code>"client_credentials"</code>
          # - <code>"implicit"</code>
          # - <code>"password"</code>
          #
          # Values are OAuthFlow objects.
          attribute :oauth_flows, { String => OAuthFlow },
                    keys: %w[authorization_code client_credentials implicit password]

          # Returns a hash representing the \OpenAPI security scheme object.
          def to_openapi(version, *)
            version = Version.from(version)

            with_openapi_extensions(type: 'oauth2', description: description).tap do |h|
              if oauth_flows&.any?
                if version.major == 2
                  key, oauth_flow = oauth_flows.first
                  h[:flow] = key.to_s
                  h.merge!(oauth_flow.to_openapi(version))
                else
                  h[:flows] = oauth_flows.to_h do |key, value|
                    [key.to_s.camelize(:lower).to_sym, value.to_openapi(version)]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
