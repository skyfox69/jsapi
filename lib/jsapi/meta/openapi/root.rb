# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an \OpenAPI object.
      class Root < Base
        ##
        # :attr: callbacks
        # The reusable Callback objects. Applies to \OpenAPI 3.x.
        attribute :callbacks, { String => Callback }

        ##
        # :attr: base_path
        # The base path of the API. Applies to \OpenAPI 2.0.
        attribute :base_path, String

        ##
        # :attr: consumes
        # The MIME types the API can consume. Applies to \OpenAPI 2.0.
        attribute :consumed_mime_types, [String]

        alias :consumes :consumed_mime_types
        alias :consumes= :consumed_mime_types=
        alias :add_consumes :add_consumed_mime_type

        ##
        # :attr: external_docs
        # The optional ExternalDocumentation object.
        attribute :external_docs, ExternalDocumentation

        ##
        # :attr: host
        # The host serving the API. Applies to \OpenAPI 2.0.
        attribute :host, String

        ##
        # :attr: info
        # The Info object.
        attribute :info, Info

        ##
        # :attr: links
        # The reusable Link objects. Applies to \OpenAPI 3.x.
        attribute :links, { String => Link }

        ##
        # :attr: produces
        # The MIME types the API can produce. Applies to \OpenAPI 2.0.
        attribute :produced_mime_types, [String]

        alias :produces :produced_mime_types
        alias :produces= :produced_mime_types=
        alias :add_produces :add_produced_mime_type

        ##
        # :attr: schemes
        # The array of transfer protocols supported by the API. Possible values are:
        #
        # - <code>"http"</code>
        # - <code>"https"</code>
        # - <code>"ws"</code>
        # - <code>"wss"</code>
        #
        # Applies to \OpenAPI 2.0.
        attribute :schemes, [String], values: %w[http https ws wss]

        ##
        # :attr: security_requirements
        # The array of SecurityRequirement objects.
        attribute :security_requirements, [SecurityRequirement]

        alias add_security add_security_requirement

        ##
        # :attr_reader: security_schemes
        # The security schemes.
        attribute :security_schemes, { String => SecurityScheme }

        ##
        # :attr: servers
        # The array of Server objects. Applies to \OpenAPI 3.x.
        attribute :servers, [Server]

        ##
        # :attr: tags
        # The array of Tag objects.
        attribute :tags, [Tag]

        # Returns a hash representing the \OpenAPI object.
        def to_openapi(version, definitions)
          version = Version.from(version)
          security_schemes =
            self.security_schemes&.transform_values do |value|
              value.to_openapi(version)
            end

          if version.major == 2
            {
              swagger: '2.0',
              info: info&.to_openapi,
              host: host,
              basePath: base_path,
              schemes: schemes,
              consumes: consumed_mime_types,
              produces: produced_mime_types,
              securityDefinitions: security_schemes,
              security: security_requirements&.map(&:to_openapi),
              tags: tags&.map(&:to_openapi),
              externalDocs: external_docs&.to_openapi
            }
          else
            {
              openapi: version.minor.zero? ? '3.0.3' : '3.1.0',
              info: info&.to_openapi,
              servers: servers&.map(&:to_openapi),
              components: {
                callbacks: callbacks&.transform_values do |callback|
                  callback.to_openapi(version, definitions)
                end,
                links: links&.transform_values(&:to_openapi),
                securitySchemes: security_schemes
              }.compact.presence,
              security: security_requirements&.map(&:to_openapi),
              tags: tags&.map(&:to_openapi),
              externalDocs: external_docs&.to_openapi
            }
          end.compact
        end
      end
    end
  end
end
