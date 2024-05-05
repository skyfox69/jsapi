# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Link
        class Reference < Meta::Base
          ##
          # :attr_reader: ref
          # The name of the referred link.
          attribute :ref, String

          # Returns a hash representing the \OpenAPI reference object.
          def to_openapi(*)
            { '$ref': "#/components/links/#{ref}" }
          end
        end
      end
    end
  end
end
