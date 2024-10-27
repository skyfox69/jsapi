# frozen_string_literal: true

module Jsapi
  module Meta
    module Example
      # Refers a reusable example.
      class Reference < Model::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/examples/#{ref}" }
        end
      end
    end
  end
end
