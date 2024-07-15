# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Header
        class Model < Base
          include Extensions

          ##
          # :attr: deprecated
          # Specifies whether or not the header is deprecated.
          attribute :deprecated, values: [true, false]

          ##
          # :attr: description
          # The description of the header.
          attribute :description, String

          ##
          # :attr_reader: examples
          # The examples.
          attribute :examples, { String => Example }, default_key: 'default'

          ##
          # :attr_reader: schema
          # The Schema of the parameter.
          attribute :schema, writer: false

          delegate_missing_to :schema

          def initialize(keywords = {})
            keywords = keywords.dup
            super(keywords.extract!(:deprecated, :description, :examples))

            add_example(value: keywords.delete(:example)) if keywords.key?(:example)
            keywords[:ref] = keywords.delete(:schema) if keywords.key?(:schema)

            @schema = Schema.new(keywords)
          end

          def to_openapi(version)
            version = OpenAPI::Version.from(version)

            with_openapi_extensions(
              if version.major == 2
                {
                  description: description
                  # TODO: collectionFormat
                }.merge(schema.to_openapi(version))
              else
                {
                  description: description,
                  deprecated: deprecated?.presence,
                  schema: schema.to_openapi(version),
                  examples: examples&.transform_values(&:to_openapi)
                }
              end
            )
          end
        end
      end
    end
  end
end
