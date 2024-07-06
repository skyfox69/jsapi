# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a server object.
      class Server < Base
        include Extensions

        ##
        # :attr: description
        # The optional description of the server.
        attribute :description, String

        ##
        # :attr: url
        # The absolute or relative URL of the server.
        attribute :url, String

        ##
        # :attr_reader: variables
        # The optional server variables.
        attribute :variables, { String => ServerVariable }

        # Returns a hash representing the server object.
        def to_openapi(*)
          with_openapi_extensions(
            url: url,
            description: description,
            variables: variables&.transform_values(&:to_openapi)
          )
        end
      end
    end
  end
end
