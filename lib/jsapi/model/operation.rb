# frozen_string_literal: true

module Jsapi
  module Model
    class Operation
      attr_accessor :description, :path, :request_body, :summary, :tags
      attr_reader :name, :parameters, :responses
      attr_writer :deprecated, :method

      def initialize(name, **options)
        raise ArgumentError, "operation name can't be blank" if name.blank?

        @name = name.to_s
        @method = options[:method]
        @path = options[:path]
        @tags = options[:tags]
        @summary = options[:summary]
        @description = options[:description]
        @deprecated = options[:deprecated]
        @parameters = {}
        @responses = {}
      end

      def add_parameter(name, **options)
        raise ArgumentError, "parameter name can't be blank" if name.blank?

        parameters[name.to_s] = Parameter.new(name, **options)
      end

      def add_response(status = nil, **options)
        responses[status || 'default'] = Response.new(**options)
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

      # Returns the OpenAPI operation object as a +Hash+.
      def to_openapi_operation
        {
          operationId: name,
          tags: tags,
          summary: summary,
          description: description,
          deprecated: deprecated?,
          parameters: parameters.values.flat_map(&:to_openapi_parameters),
          request_body: request_body&.to_openapi_request_body,
          responses: responses.transform_values(&:to_openapi_response)
        }.compact
      end
    end
  end
end
