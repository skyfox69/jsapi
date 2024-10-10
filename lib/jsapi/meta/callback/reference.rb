# frozen_string_literal: true

module Jsapi
  module Meta
    module Callback
      class Reference < Base::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(*)
          { '$ref': "#/components/callbacks/#{ref}" }
        end
      end
    end
  end
end
