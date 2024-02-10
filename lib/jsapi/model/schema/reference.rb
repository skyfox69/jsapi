# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Reference
        attr_reader :existence, :reference

        def initialize(reference, existence: nil)
          @reference = reference
          @existence = Existence.from(existence)
        end

        def existence=(existence)
          @existence = Existence.from(existence)
        end

        # Resolves the reference by looking up the reusable schema in +definitions+.
        # Raises a +ReferenceError+ if the reference could not be resolved.
        def resolve(definitions)
          schema = definitions.schema(@reference)
          raise ReferenceError, @reference if schema.nil?

          schema = schema.resolve(definitions)
          return schema if existence < Existence::ALLOW_EMPTY

          Decorator.new(schema, [existence, schema.existence].max)
        end

        # Returns the JSON schema as a +Hash+.
        def to_json_schema(*)
          { '$ref': "#/definitions/#{@reference}" }
        end

        # Returns the OpenAPI schema object as a +Hash+.
        def to_openapi_schema
          { '$ref': "#/components/schemas/#{@reference}" }
        end
      end
    end
  end
end
