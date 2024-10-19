# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      # Specifies a response reference.
      class Reference < Base::Reference
        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(version, *)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'responses' : 'components/responses'

          { '$ref': "#/#{path}/#{ref}" }
        end
      end
    end
  end
end
