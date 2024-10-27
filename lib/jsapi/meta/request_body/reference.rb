# frozen_string_literal: true

module Jsapi
  module Meta
    module RequestBody
      # Refers a reusable request body.
      class Reference < Model::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/requestBodies/#{ref}" }
        end
      end
    end
  end
end
