# frozen_string_literal: true

module Jsapi
  module Model
    module Parameter
      class Reference
        attr_reader :reference

        def initialize(reference)
          @reference = reference
        end

        # Resolves the reference by looking up the reusable parameter in +definitions+.
        # Raises a +ReferenceError+ if the reference could not be resolved.
        def resolve(definitions)
          parameter = definitions.parameter(reference)
          raise ReferenceError, reference if parameter.nil?

          parameter
        end

        # Returns the OpenAPI reference object or the OpenAPI parameter objects of the
        # referred parameter as an array of hashes. Raises a +ReferenceError+ if the
        # reference could not be resolved.
        def to_openapi_parameters(version, definitions)
          parameter = resolve(definitions)

          if parameter.schema.resolve(definitions).object?
            # Explode referred parameter
            parameter.to_openapi_parameters(version, definitions)
          else
            # Return an array containing the reference object
            path = version == '2.0' ? 'parameters' : 'components/parameters'

            [{ '$ref': "#/#{path}/#{reference}" }]
          end
        end
      end
    end
  end
end
