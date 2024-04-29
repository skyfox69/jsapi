# frozen_string_literal: true

module Jsapi
  module Meta
    class RequestBody < Base
      ##
      # :attr: description
      # The optional description of the request body.
      attribute :description, String

      ##
      # :attr_reader: examples
      # The optional examples.
      attribute :examples, { String => Example }, default_key: 'default'

      ##
      # :attr_reader: schema
      # The Schema of the parameter.
      attribute :schema, writer: false

      delegate_missing_to :schema

      # Creates a new request body.
      def initialize(keywords = {})
        keywords = keywords.dup
        super(keywords.extract!(:description, :examples))

        add_example(value: keywords.delete(:example)) if keywords.key?(:example)

        @schema = Schema.new(keywords)
      end

      # Returns true if the request body is required, false otherwise.
      def required?
        schema.existence > Existence::ALLOW_OMITTED
      end

      # Returns a hash representing the \OpenAPI 2.0 parameter object.
      def to_openapi_parameter
        {
          name: 'body',
          in: 'body',
          description: description,
          required: required?
        }.merge(schema.to_openapi_schema('2.0')).compact
      end

      # Returns a hash representing the \OpenAPI 3.x request body object.
      def to_openapi_request_body(version)
        {
          description: description,
          content: {
            'application/json' => {
              schema: schema.to_openapi_schema(version),
              examples: examples&.transform_values(&:to_openapi_example)
            }.compact
          },
          required: required?
        }.compact
      end
    end
  end
end
