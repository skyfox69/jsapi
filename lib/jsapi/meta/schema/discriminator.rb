# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Discriminator < Meta::Base
        ##
        # :attr: mappings
        attribute :mappings, { Object => String }

        ##
        # :attr: property_name
        attribute :property_name, String

        # Looks up the inherriting schema for +value+ in +definitions+.
        def resolve(value, definitions)
          schema = definitions.schema(mapping(value) || value)
          raise "inherriting schema not found: #{value.inspect}" unless schema

          schema.resolve(definitions)
        end

        # Returns a hash representing the \OpenAPI discriminator object.
        def to_openapi(version)
          version = OpenAPI::Version.from(version)
          return property_name if version.major == 2

          {
            propertyName: property_name,
            mapping: mappings&.transform_keys(&:to_s)
          }.compact
        end
      end
    end
  end
end
