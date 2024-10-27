# frozen_string_literal: true

module Jsapi
  module Meta
    module Callback
      # Refers a reusable callback.
      class Reference < Model::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/callbacks/#{ref}" }
        end
      end
    end
  end
end
