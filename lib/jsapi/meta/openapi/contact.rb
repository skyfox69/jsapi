# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a contact object.
      class Contact < Base
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

        # Returns a hash representing the contact object.
        def to_openapi(*)
          {
            name: name,
            url: url,
            email: email
          }.compact
        end
      end
    end
  end
end
