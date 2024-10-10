# frozen_string_literal: true

module Jsapi
  module Meta
    # Specifies an external documentation object.
    class ExternalDocumentation < Base::Model
      include OpenAPI::Extensions

      ##
      # :attr: description
      # The description of the external documentation.
      attribute :description, String

      ##
      # :attr: url
      # The URL of the external documentation.
      attribute :url, String

      # Returns a hash representing the \OpenAPI external documentation object.
      def to_openapi(*)
        with_openapi_extensions(url: url, description: description)
      end
    end
  end
end
