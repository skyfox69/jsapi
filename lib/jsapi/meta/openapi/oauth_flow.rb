# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an OAuth flow object.
      class OAuthFlow < Object
        class Scope < Object
          attr_accessor :description
        end

        attr_accessor :authorization_url, :token_url, :refresh_url
        attr_reader :scopes

        def initialize(**keywords)
          @scopes = {}
          super
        end

        def add_scope(name, keywords = {})
          raise ArgumentError, "name can't be blank" if name.blank?

          @scopes[name] = Scope.new(**keywords)
        end

        def to_h(version)
          {
            authorizationUrl: authorization_url&.to_s,
            tokenUrl: token_url&.to_s,
            refreshUrl: (refresh_url&.to_s if version.major > 2),
            scopes: scopes.transform_values { |s| s.description || '' }
          }.compact
        end
      end
    end
  end
end
