# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module SecurityScheme
        module HTTP
          # Represents a security scheme based on any other \HTTP authentication
          # than basic and bearer.
          #
          # Note that \OpenAPI 2.0 supports \HTTP basic authentication only. Thus,
          # a security scheme of this class is skipped when generating an
          # \OpenAPI 2.0 document.
          class Other < Base
            ##
            # :attr: scheme
            # The mandatory \HTTP authentication scheme.
            attribute :scheme, String

            # Returns a hash representing the security scheme object, or +nil+
            # if <code>version.major</code> is 2.
            def to_openapi(version)
              return if version.major == 2

              {
                type: 'http',
                scheme: scheme,
                description: description
              }.compact
            end
          end
        end
      end
    end
  end
end
