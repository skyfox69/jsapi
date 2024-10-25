# frozen_string_literal: true

module Jsapi
  module Meta
    # Specifies a license object.
    class License < Model::Base
      include OpenAPI::Extensions

      ##
      # :attr: name
      # The name of the license.
      attribute :name, String

      ##
      # :attr: url
      # The URL of the license.
      attribute :url, String

      # Returns a hash representing the \OpenAPI license object.
      def to_openapi(*)
        with_openapi_extensions(name: name, url: url)
      end
    end
  end
end
