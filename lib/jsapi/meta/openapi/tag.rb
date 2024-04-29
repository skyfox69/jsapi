# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a tag object.
      class Tag < Base
        ##
        # :attr: description
        # The description of the tag.
        attribute :description, String

        ##
        # :attr: external_docs
        # The ExternalDocumentation object.
        attribute :external_docs, ExternalDocumentation

        ##
        # :attr: name
        # The name of the tag.
        attribute :name, String

        # Returns a hash representing the tag object.
        def to_openapi
          {
            name: name,
            description: description,
            externalDocs: external_docs&.to_openapi
          }.compact
        end
      end
    end
  end
end
