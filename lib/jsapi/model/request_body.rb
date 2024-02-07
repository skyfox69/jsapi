# frozen_string_literal: true

module Jsapi
  module Model
    class RequestBody
      attr_accessor :description, :example
      attr_reader :schema

      def initialize(**options)
        @description = options[:description]
        @example = options[:example]
        @schema = Schema.new(**options.except(:description, :example, :required))

        self.required = options[:required] == true
      end

      def required?
        @required == true
      end

      def required=(required)
        @required = required == true
        @schema.nullable = !@required if @schema.respond_to?(:nullable=)
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
