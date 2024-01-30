# frozen_string_literal: true

module Jsapi
  module Model
    class Response
      attr_accessor :description, :example
      attr_reader :schema

      def initialize(**options)
        @description = options[:description]
        @example = options[:example]
        @schema = Schema.new(**options.except(:description, :example))
      end

      # Returns the OpenAPI response object as a +Hash+.
      def to_openapi_response
        {
          description: description,
          content: {
            'application/json' => {
              schema: schema.to_openapi_schema
            }
          },
          example: example
        }.compact
      end
    end
  end
end
