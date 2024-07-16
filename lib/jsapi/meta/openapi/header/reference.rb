# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Header
        class Reference < BaseReference
          # Returns a hash representing the \OpenAPI reference object.
          def to_openapi(*)
            { '$ref': "#/components/headers/#{ref}" }
          end
        end
      end
    end
  end
end
