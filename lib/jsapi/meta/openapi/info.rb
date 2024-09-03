# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an info object.
      class Info < Meta::Base::Model
        include Extensions

        ##
        # :attr: contact
        # The optional Contact object.
        attribute :contact, Contact

        ##
        # :attr: description
        # The optional description of the API.
        attribute :description, String

        ##
        # :attr: license
        # The optional License object.
        attribute :license, License

        ##
        # :attr: terms_of_service
        # The optional URL pointing to the terms of service.
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
end
