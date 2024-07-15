# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Example
        class Reference < BaseReference
          # Returns a hash representing the \OpenAPI reference object.
          def to_openapi(*)
            { '$ref': "#/components/examples/#{ref}" }
          end
        end
      end
    end
  end
end
