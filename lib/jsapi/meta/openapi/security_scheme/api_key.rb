# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        # Represents a security scheme based on an API key.
        class APIKey < Base
          ##
          # :attr: in
          # The location of the API key. Possible values are:
          #
          # - <code>"cookie"</code>
          # - <code>"header"</code>
          # - <code>"query"</code>
          #
          attribute :in, String, values: %w[cookie header query]

          ##
          # :attr: name
          # The name of the header, query parameter or cookie the
          # API key is sent by.
          attribute :name, String

          # Returns a hash representing the security scheme object.
          def to_openapi(*)
            {
              type: 'apiKey',
              name: name,
              in: self.in,
              description: description
            }.compact
          end
        end
      end
    end
  end
end
