# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Reference < Meta::Base
        ##
        # :attr: existence
        # The level of Existence. The default level of existence
        # is +ALLOW_OMITTED+.
        attribute :existence, Existence, default: Existence::ALLOW_OMITTED

        ##
        # :attr: schema
        # The name of the referred schema as a string.
        attribute :schema, String

        # Resolves the reference by looking up the reusable schema in +definitions+.
        #
        # Raises a +ReferenceError+ if the reference could not be resolved.
        def resolve(definitions)
          schema = definitions.schema(self.schema)
          raise ReferenceError, self.schema if schema.nil?

          schema = schema.resolve(definitions)
          return schema if existence < Existence::ALLOW_EMPTY

          Delegator.new(schema, [existence, schema.existence].max)
        end

        # Returns a hash representing the \JSON \Schema reference object.
        def to_json_schema
          { '$ref': "#/definitions/#{schema}" }
        end

        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi_schema(version)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'definitions' : 'components/schemas'

          { '$ref': "#/#{path}/#{schema}" }
        end
      end
    end
  end
end
