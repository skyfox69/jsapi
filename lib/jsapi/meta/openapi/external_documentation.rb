# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an external documentation object.
      class ExternalDocumentation < Base
        include Extensions

        ##
        # :attr: description
        # The optional description of the external documentation.
        attribute :description, String

        ##
        # :attr: url
        # The URL of the external documentation.
        attribute :url, String

        # Returns a hash representing the external documentation object.
        def to_openapi(*)
          with_openapi_extensions(url: url, description: description)
        end
      end
    end
  end
end
