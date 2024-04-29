# frozen_string_literal: true

module Jsapi
  module Meta
    class Operation < Base
      ##
      # :attr: consumed_mime_types
      # The MIME types consumed by the operation.
      # Applies to \OpenAPI 2.0 only.
      attribute :consumed_mime_types, [String]

      alias :consumes :consumed_mime_types
      alias :consumes= :consumed_mime_types=
      alias :add_consumes :add_consumed_mime_type

      ##
      # :attr: deprecated
      # Specifies whether or not the operation is deprecated.
      attribute :deprecated, values: [true, false]

      ##
      # :attr: description
      # The optional description of the operation.
      attribute :description, String

      ##
      # :attr: external_docs
      # The optional OpenAPI::ExternalDocumentation object.
      attribute :external_docs, OpenAPI::ExternalDocumentation

      ##
      # :attr: method
      # The HTTP verb of the operation. Possible values are:
      #
      # - <code>"delete"</code>
      # - <code>"get"</code>
      # - <code>"head"</code>
      # - <code>"options"</code>
      # - <code>"patch"</code>
      # - <code>"post"</code>
      # - <code>"put"</code>
      #
      # The default HTTP verb is <code>"get"</code>.
      attribute :method,
                values: %w[delete get head options patch post put],
                default: 'get'

      ##
      # :attr: model
      # The model class to access top-level parameters by. The default
      # model class is Model::Base.
      attribute :model, Class, default: Model::Base

      ##
      # :attr_reader: name
      # The name of the operation.
      attribute :name, writer: false

      ##
      # :attr: parameters
      # The parameters of the operation.
      attribute :parameters, { String => Parameter },
                default: {},
                writer: false

      ##
      # :attr: path
      # The relative path of the operation.
      attribute :path, String

      ##
      # :attr: consumed_mime_types
      # The MIME types produced by the operation.
      # Applies to \OpenAPI 2.0 only.
      attribute :produced_mime_types, [String]

      alias :produces :produced_mime_types
      alias :produces= :produced_mime_types=
      alias :add_produces :add_produced_mime_type

      ##
      # :attr: request_body
      # The optional request body of the operation.
      attribute :request_body, RequestBody

      ##
      # :attr: responses
      # The responses of the operation.
      attribute :responses, { String => Response },
                default: {},
                default_key: 'default'

      ##
      # :attr: schemes
      # The transfer protocols supported by the operation. Possible
      # values are:
      #
      # - <code>"http"</code>
      # - <code>"https"</code>
      # - <code>"ws"</code>
      # - <code>"wss"</code>
      #
      # Applies to \OpenAPI 2.0 only.
      attribute :schemes, [String], values: %w[http https ws wss]

      ##
      # :attr: security_requirements
      # The OpenAPI::SecurityRequirement objects.
      attribute :security_requirements, [OpenAPI::SecurityRequirement]

      alias add_security add_security_requirement

      ##
      # :attr: servers
      # The OpenAPI::Server objects. Applies to \OpenAPI 3.x.
      attribute :servers, [OpenAPI::Server]

      ##
      # :attr: summary
      # The optional summary of the operation.
      attribute :summary, String

      ##
      # :attr: tags
      # The tags used to group operations in an \OpenAPI document.
      attribute :tags, [String]

      # Creates a new operation.
      #
      # Raises an +ArgumentError+ if +name+ is blank.
      def initialize(name, keywords = {})
        raise ArgumentError, "operation name can't be blank" if name.blank?

        @name = name.to_s
        super(keywords)
      end

      def add_parameter(name, keywords = {}) # :nodoc:
        (@parameters ||= {})[name.to_s] = Parameter.new(name, **keywords)
      end

      # Returns a hash representing the \OpenAPI operation object.
      def to_openapi_operation(version, definitions)
        version = OpenAPI::Version.from(version)
        {
          operationId: name,
          tags: tags,
          summary: summary,
          description: description,
          externalDocs: external_docs&.to_openapi,
          deprecated: deprecated?.presence,
          security: security_requirements&.map(&:to_openapi)
        }.tap do |hash|
          if version.major == 2
            hash[:consumes] = consumed_mime_types if consumed_mime_types
            hash[:produces] = produced_mime_types if produced_mime_types
            hash[:schemes] = schemes if schemes
          elsif servers
            hash[:servers] = servers.map(&:to_openapi)
          end
          # Parameters (and request body)
          hash[:parameters] = parameters.values.flat_map do |parameter|
            parameter.to_openapi_parameters(version, definitions)
          end
          if request_body
            if version.major == 2
              hash[:parameters] << request_body.to_openapi_parameter
            else
              hash[:request_body] = request_body.to_openapi_request_body(version)
            end
          end
          # Responses
          hash[:responses] = responses.transform_values do |response|
            response.to_openapi_response(version)
          end
        end.compact
      end
    end
  end
end
