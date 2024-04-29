# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Reference < Meta::Base
        ##
        # :attr_reader:
        # The name of the referred response.
        attribute :response, String

        # Resolves the reference by looking up the reusable response with the
        # given name in +definitions+.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def resolve(definitions)
          response = definitions.response(self.response)
          raise ReferenceError, self.response if response.nil?

          response.resolve(definitions)
        end

        # Returns a hash representing the \OpenAPI reference object.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def to_openapi_response(version)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'responses' : 'components/responses'

          { '$ref': "#/#{path}/#{response}" }
        end
      end
    end
  end
end
