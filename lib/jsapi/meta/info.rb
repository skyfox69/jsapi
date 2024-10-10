# frozen_string_literal: true

module Jsapi
  module Meta
    # Specifies an info object.
    class Info < Base::Model
      include OpenAPI::Extensions

      ##
      # :attr: contact
      # The Contact object.
      attribute :contact, Contact

      ##
      # :attr: description
      # The description of the API.
      attribute :description, String

      ##
      # :attr: license
      # The License object.
      attribute :license, License

      ##
      # :attr: terms_of_service
      # The URL pointing to the terms of service.
      attribute :terms_of_service, String

      ##
      # :attr: title
      # The title of the API.
      attribute :title, String

      ##
      # :attr: version
      # The version of the API.
      attribute :version, String

      # Returns a hash representing the \OpenAPI info object.
      def to_openapi(*)
        with_openapi_extensions(
          title: title,
          version: version,
          description: description,
          termsOfService: terms_of_service,
          contact: contact&.to_openapi,
          license: license&.to_openapi
        )
      end
    end
  end
end
