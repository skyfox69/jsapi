# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a server variable object.
      class ServerVariable < Base
        include Extensions

        ##
        # :attr: default
        # The default value of the server variable.
        attribute :default, String

        ##
        # :attr: description
        # The optional description of the server variable.
        attribute :description, String

        ##
        # :attr: enum
        # The values of the server variable.
        attribute :enum, [String]

        # Returns a hash representing the server variable object.
        def to_openapi(*)
          with_openapi_extensions(
            default: default,
            enum: enum.presence, # must not be empty
            description: description
          )
        end
      end
    end
  end
end
