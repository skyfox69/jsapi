# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      module ToOpenAPI
        # Returns a hash representing the \OpenAPI parameter or reference object.
        def to_openapi(version, definitions)
          to_openapi_parameters(version, definitions).first
        end
      end
    end
  end
end
