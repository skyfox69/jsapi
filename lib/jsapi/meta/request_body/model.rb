# frozen_string_literal: true

module Jsapi
  module Meta
    module RequestBody
      class Model < Base
        include OpenAPI::Extensions

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
        # The Schema of the request body.
        attribute :schema, writer: false

        delegate_missing_to :schema

        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:description, :examples))

          add_example(value: keywords.delete(:example)) if keywords.key?(:example)
          keywords[:ref] = keywords.delete(:schema) if keywords.key?(:schema)

          @schema = Schema.new(keywords)
        end

        # Returns true if the level of existence is greater than or equal to
        # +ALLOW_NIL+, false otherwise.
        def required?
          schema.existence >= Existence::ALLOW_NIL
        end

        # Returns a hash representing the \OpenAPI 2.0 parameter object.
        def to_openapi_parameter
          {
            name: 'body',
            in: 'body',
            description: description,
            required: required?
          }.merge(schema.to_openapi('2.0')).merge(openapi_extensions).compact
        end

        # Returns a hash representing the \OpenAPI 3.x request body object.
        def to_openapi(version)
          with_openapi_extensions(
            description: description,
            content: {
              'application/json' => {
                schema: schema.to_openapi(version),
                examples: examples&.transform_values(&:to_openapi)
              }.compact
            },
            required: required?
          )
        end
      end
    end
  end
end
