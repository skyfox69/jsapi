# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Reference
        attr_reader :reference

        def initialize(reference)
          @reference = reference
        end

        # Resolves the reference by looking up the reusable response in +definitions+.
        # Raises a +ReferenceError+ if the reference could not be resolved.
        def resolve(definitions)
          response = definitions.response(@reference)
          raise ReferenceError, @reference if response.nil?

          response.resolve(definitions)
        end

        # Returns the OpenAPI reference object as a +Hash+.
        def to_openapi_response(version)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'responses' : 'components/responses'

          { '$ref': "#/#{path}/#{@reference}" }
        end
      end
    end
  end
end
