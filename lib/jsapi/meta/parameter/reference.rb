# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      # Refers a reusable parameter.
      class Reference < Model::Reference
        # Returns an array of hashes representing the \OpenAPI parameter or reference objects.
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
            [to_openapi(version)]
          end
        end
      end
    end
  end
end
