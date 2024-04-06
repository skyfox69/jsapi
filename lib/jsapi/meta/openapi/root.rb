# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      # Represents an OpenAPI object.
      class Root < Object
        SCHEMES = %w[http https ws wss].freeze

        attr_accessor :base_path, :host

        attr_reader :consumes, :external_docs, :info, :produces, :security_requirements,
                    :schemes, :security_schemes, :servers, :tags

        # TODO: validates :info, presence: true

        def add_consumes(mime_type)
          raise ArgumentError, "mime type can't be blank" if mime_type.blank?

          (@consumes ||= []) << mime_type
        end

        def add_produces(mime_type)
          raise ArgumentError, "mime type can't be blank" if mime_type.blank?

          (@produces ||= []) << mime_type
        end

        def add_scheme(scheme)
          raise ArgumentError, "invalid scheme: #{scheme.inspect}" unless scheme.in?(SCHEMES)

          (@schemes ||= []) << scheme
        end

        def add_security(keywords = {})
          SecurityRequirement.new(**keywords).tap do |security|
            (@security_requirements ||= []) << security
          end
        end

        def add_security_scheme(name, keywords = {})
          raise ArgumentError, "name can't be blank" if name.blank?

          (@security_schemes ||= {})[name.to_s] = SecurityScheme.new(**keywords)
        end

        def add_server(keywords = {})
          Server.new(**keywords).tap do |server|
            (@servers ||= []) << server
          end
        end

        def add_tag(keywords = {})
          Tag.new(**keywords).tap do |tag|
            (@tags ||= []) << tag
          end
        end

        def consumes=(mime_types)
          @consumes = Array(mime_types)
        end

        def external_docs=(keywords = {})
          @external_docs = ExternalDocumentation.new(**keywords)
        end

        def info=(keywords = {})
          @info = Info.new(**keywords)
          Info.new(**keywords)
        end

        def produces=(mime_types)
          @produces = Array(mime_types)
        end

        def schemes=(schemes)
          schemes = Array(schemes)

          if (invalid_schemes = schemes - SCHEMES).any?
            invalid_schemes = invalid_schemes.map(&:inspect).join(', ')
            raise ArgumentError, "invalid schemes: #{invalid_schemes}"
          end

          @schemes = schemes
        end

        def to_h(version)
          security_schemes =
            self.security_schemes&.transform_values do |value|
              value.to_h(version)
            end&.compact

          if version.major == 2
            {
              swagger: '2.0',
              info: info&.to_h,
              host: host&.to_s,
              basePath: base_path&.to_s,
              schemes: schemes.presence,
              consumes: consumes.presence,
              produces: produces.presence,
              securityDefinitions: security_schemes,
              security: security_requirements&.map(&:to_h),
              tags: tags&.map(&:to_h),
              externalDocs: external_docs&.to_h
            }
          else
            {
              openapi: version.minor.zero? ? '3.0.3' : '3.1.0',
              info: info&.to_h,
              servers: servers&.map(&:to_h),
              components: {
                securitySchemes: security_schemes
              }.compact.presence,
              security: security_requirements&.map(&:to_h),
              tags: tags&.map(&:to_h),
              externalDocs: external_docs&.to_h
            }
          end.compact
        end
      end
    end
  end
end
