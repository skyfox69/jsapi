# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Reference < Meta::Base
        ##
        # :attr_reader: ref
        # The name of the referred response.
        attribute :ref, String

        # Resolves the reference by looking up the reusable response with the
        # given name in +definitions+.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def resolve(definitions)
          response = definitions.response(ref)
          raise ReferenceError, ref if response.nil?

          response.resolve(definitions)
        end

        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi(version)
          version = OpenAPI::Version.from(version)
          path = version.major == 2 ? 'responses' : 'components/responses'

          { '$ref': "#/#{path}/#{ref}" }
        end
      end
    end
  end
end
