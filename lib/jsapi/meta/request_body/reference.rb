# frozen_string_literal: true

module Jsapi
  module Meta
    module RequestBody
      class Reference < Base::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/requestBodies/#{ref}" }
        end
      end
    end
  end
end
