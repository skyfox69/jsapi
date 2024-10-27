# frozen_string_literal: true

module Jsapi
  module Meta
    module Link
      # Refers a reusable link.
      class Reference < Model::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/links/#{ref}" }
        end
      end
    end
  end
end
