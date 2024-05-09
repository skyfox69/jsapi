# frozen_string_literal: true

module Jsapi
  module Meta
    module RequestBody
      class Reference < Meta::Base
        ##
        # :attr_reader: ref
        # The name of the referred response.
        attribute :ref, String

        # Resolves the reference by looking up the reusable request body with
        # the given name in +definitions+.
        #
        # Raises a ReferenceError if the reference could not be resolved.
        def resolve(definitions)
          request_body = definitions.request_body(ref)
          raise ReferenceError, ref if request_body.nil?

          request_body.resolve(definitions)
        end

        # Returns a hash representing the \OpenAPI reference object.
        def to_openapi_request_body(*)
          { '$ref': "#/components/requestBodies/#{ref}" }
        end
      end
    end
  end
end
