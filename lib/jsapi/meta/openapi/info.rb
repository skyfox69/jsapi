# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an info object.
      class Info < Object
        attr_accessor :description, :terms_of_service, :title, :version
        attr_reader :contact, :license

        # TODO: validates :title, :version, presence: true

        def contact=(keywords)
          @contact = Contact.new(**keywords)
        end

        def license=(keywords)
          @license = License.new(**keywords)
        end

        def to_h
          {
            title: title&.to_s,
            description: description&.to_s,
            termsOfService: terms_of_service&.to_s,
            contact: contact&.to_h,
            license: license&.to_h,
            version: version&.to_s
          }.compact
        end
      end
    end
  end
end
