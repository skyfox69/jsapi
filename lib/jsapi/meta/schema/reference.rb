# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Reference < BaseReference
        alias :schema :ref
        alias :schema= :ref=

        ##
        # :attr: existence
        # The level of Existence. The default level of existence
        # is +ALLOW_OMITTED+.
        attribute :existence, Existence, default: Existence::ALLOW_OMITTED

        def resolve(definitions) # :nodoc:
          schema = super
          return schema if existence < Existence::ALLOW_EMPTY

          Delegator.new(schema, [existence, schema.existence].max)
        end

        # Returns a hash representing the \JSON \Schema reference object.
        def to_json_schema
          { '$ref': "#/definitions/#{ref}" }
        end

        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(version)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'definitions' : 'components/schemas'

          { '$ref': "#/#{path}/#{ref}" }
        end
      end
    end
  end
end
