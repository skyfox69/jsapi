# frozen_string_literal: true

module Jsapi
  module Meta
    module Header
      class Reference < Base::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/headers/#{ref}" }
        end
      end
    end
  end
end
