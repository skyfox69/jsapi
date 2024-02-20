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
      def to_openapi_response(version)
        { description: description }.tap do |hash|
          case version
          when '2.0'
            hash.merge!(
              schema: schema.to_openapi_schema(version),
              examples: example
            )
          when '3.0.3'
            hash.merge!(
              content: {
                'application/json' => {
                  schema: schema.to_openapi_schema(version)
                }
              },
              example: example
            )
          end
        end.compact
      end
    end
  end
end
