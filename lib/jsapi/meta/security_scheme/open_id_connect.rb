# frozen_string_literal: true

module Jsapi
  module Meta
    module SecurityScheme
      # Specifies a security scheme based on OpenID Connect.
      #
      # OpenID Connect was introduced with \OpenAPI 3.0. Thus, a security scheme of
      # this class is skipped when generating an \OpenAPI 2.0 document.
      class OpenIDConnect < Base
        include OpenAPI::Extensions

        ##
        # :attr: open_id_connect_url
        attribute :open_id_connect_url, String

        # Returns a hash representing the \OpenAPI security scheme object, or +nil+
        # if <code>version.major</code> is 2.
        def to_openapi(version, *)
          version = OpenAPI::Version.from(version)
          return if version.major == 2

          with_openapi_extensions(
            type: 'openIdConnect',
            openIdConnectUrl: open_id_connect_url,
            description: description
          )
        end
      end
    end
  end
end
