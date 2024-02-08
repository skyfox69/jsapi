# frozen_string_literal: true

module Jsapi
  module Model
    class RequestBody
      attr_accessor :description, :example
      attr_reader :schema

      def initialize(**options)
        @description = options[:description]
        @example = options[:example]
        @schema = Schema.new(**options.except(:description, :example))
      end

      def required?
        schema.existence > Existence::ALLOW_OMITTED
      end

      # Returns the OpenAPI request body object as a +Hash+.
      def to_openapi_request_body
        {
          description: description,
          content: {
            'application/json' => {
              schema: schema.to_openapi_schema
            }
          },
          required: required?,
          example: example
        }.compact
      end
    end
  end
end
