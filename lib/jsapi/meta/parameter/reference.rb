# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      # Refers a reusable parameter.
      class Reference < Model::Reference
        include ToOpenAPI

        # Returns an array of hashes. If the type of the referred parameter is
        # <code>"object"</code>, each hash represents an \OpenAPI parameter object.
        # Otherwise the array contains a single hash representing the \OpenAPI
        # reference object.
        #
        # Raises a ReferenceError when the reference could not be resolved.
        def to_openapi_parameters(version, definitions)
          version = OpenAPI::Version.from(version)
          parameter = resolve(definitions)

          if parameter.schema.resolve(definitions).object?
            # Explode referred parameter
            parameter.to_openapi_parameters(version, definitions)
          else
            # Return an array containing the reference object
            path = version.major == 2 ? 'parameters' : 'components/parameters'

            [{ '$ref': "#/#{path}/#{ref}" }]
          end
        end
      end
    end
  end
end
