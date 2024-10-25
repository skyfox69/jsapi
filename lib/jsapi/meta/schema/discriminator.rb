# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Discriminator < Model::Base
        ##
        # :attr: mappings
        attribute :mappings, { Object => String }

        ##
        # :attr: property_name
        attribute :property_name, String

        # Returns a hash representing the \OpenAPI discriminator object.
        def to_openapi(version, *)
          version = OpenAPI::Version.from(version)
          return property_name if version.major == 2

          {
            propertyName: property_name,
            mapping: mappings.transform_keys(&:to_s).presence
          }.compact
        end
      end
    end
  end
end
