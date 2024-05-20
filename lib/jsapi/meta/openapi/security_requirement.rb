# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents a security requirement object.
      class SecurityRequirement < Base
        class Scheme < Base
          ##
          # :attr: scopes
          # The array of scopes.
          attribute :scopes, [String], default: []
        end

        ##
        # :attr_reader: schemes
        # The schemes.
        attribute :schemes, { String => Scheme }

        # Returns a hash representing the security requirement object.
        def to_openapi(*)
          schemes&.transform_values(&:scopes) || {}
        end
      end
    end
  end
end
