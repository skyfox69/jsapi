# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        class Reference < Meta::Base
          ##
          # :attr_reader: ref
          # The name of the referred callback.
          attribute :ref, String

          # Returns a hash representing the \OpenAPI reference object.
          def to_openapi(*)
            { '$ref': "#/components/callbacks/#{ref}" }
          end
        end
      end
    end
  end
end
