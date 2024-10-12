# frozen_string_literal: true

module Jsapi
  module Meta
    # Specifies a tag object.
    class Tag < Base::Model
      include OpenAPI::Extensions

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

      # Returns a hash representing the \OpenAPI tag object.
      def to_openapi(*)
        with_openapi_extensions(
          name: name,
          description: description,
          externalDocs: external_docs&.to_openapi
        )
      end
    end
  end
end
