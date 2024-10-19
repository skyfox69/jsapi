# frozen_string_literal: true

module Jsapi
  module Meta
    module Example
      # Specifies an example reference.
      class Reference < Base::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/examples/#{ref}" }
        end
      end
    end
  end
end
