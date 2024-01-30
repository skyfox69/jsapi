# frozen_string_literal: true

module Jsapi
  module Model
    module Parameter
      class Reference < Model::Reference
        # Resolves the reference by looking up the reusable parameter in +definitions+.
        # Raises a +ReferenceError+ if the reference could not be resolved.
        def resolve(definitions)
          parameter = definitions.parameter(reference)
          raise ReferenceError, reference if parameter.nil?

          parameter
        end

        # Returns the OpenAPI reference object as an array containing a single hash.
        def to_openapi_parameters
          [{ '$ref': "#{COMPONENTS}/parameters/#{reference}" }]
        end
      end
    end
  end
end
