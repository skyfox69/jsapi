# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a contact object.
      class Contact < Object
        attr_accessor :email, :name, :url

        def to_h
          {
            name: name&.to_s,
            url: url&.to_s,
            email: email&.to_s
          }.compact
        end
      end
    end
  end
end
