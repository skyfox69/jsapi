# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Header
        class Model < Meta::Base::Model
          include Extensions

          delegate_missing_to :schema

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
          # One or more example values.
          attribute :examples, { String => Example }, default_key: 'default'

          ##
          # :attr_reader: schema
          # The Schema of the header.
          attribute :schema, writer: false

          def initialize(keywords = {})
            keywords = keywords.dup
            super(keywords.extract!(:deprecated, :description, :examples))

            add_example(value: keywords.delete(:example)) if keywords.key?(:example)

            @schema = Schema.new(keywords)
          end

          # Returns a hash representing the \OpenAPI header object.
          def to_openapi(version)
            version = OpenAPI::Version.from(version)

            with_openapi_extensions(
              if version.major == 2
                schema.to_openapi(version).merge(
                  description: description
                )
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
