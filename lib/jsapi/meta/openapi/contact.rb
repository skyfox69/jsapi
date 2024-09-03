# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a contact object.
      class Contact < Meta::Base::Model
        include Extensions

        ##
        # :attr: email
        # The email address of the contact.
        attribute :email, String

        ##
        # :attr: name
        # The name of the contact.
        attribute :name, String

        ##
        # :attr: url
        # The URL of the contact.
        attribute :url, String

        # Returns a hash representing the \OpenAPI contact object.
        def to_openapi(*)
          with_openapi_extensions(name: name, url: url, email: email)
        end
      end
    end
  end
end
