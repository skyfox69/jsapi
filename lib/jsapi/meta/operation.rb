# frozen_string_literal: true

module Jsapi
  module Meta
    class Operation
      attr_accessor :description, :model, :path, :summary, :tags
      attr_reader :name, :parameters, :request_body, :responses
      attr_writer :deprecated, :method

      def initialize(name, **options)
        raise ArgumentError, "operation name can't be blank" if name.blank?

        @name = name.to_s
        @model = options[:model]
        @method = options[:method]
        @path = options[:path]
        @tags = options[:tags]
        @summary = options[:summary]
        @description = options[:description]
        @deprecated = options[:deprecated] == true
        @parameters = {}
        @responses = {}
      end

      def add_parameter(name, **options)
        parameters[name.to_s] = Parameter.new(name, **options)
      end

      def add_parameter_reference(name)
        parameters[name.to_s] = Parameter.reference(name)
      end

      def add_response(status = nil, **options)
        responses[status || 'default'] = Response.new(**options)
      end

      def add_response_reference(status, name)
        responses[status || 'default'] = Response.reference(name)
      end

      def deprecated?
        @deprecated == true
      end

      def method
        @method || 'get'
      end

      # Returns the response associated with the given status, or the default
      # response if +status+ is +nil+.
      def response(status = nil)
        responses[status || 'default']
      end

      def set_request_body(**options)
        @request_body = RequestBody.new(**options)
      end

      # Returns the OpenAPI operation object as a +Hash+.
      def to_openapi_operation(version, definitions)
        version = OpenAPI::Version.from(version)
        {
          operationId: name,
          tags: tags,
          summary: summary,
          description: description,
          deprecated: deprecated?.presence
        }.tap do |hash|
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
