# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a license object.
      class License < Base
        ##
        # :attr: name
        # The name of the license.
        attribute :name, String

        ##
        # :attr: url
        # The optional URL of the license.
        attribute :url, String

        # Returns a hash representing the license object.
        def to_openapi(*)
          {
            name: name,
            url: url
          }.compact
        end
      end
    end
  end
end
