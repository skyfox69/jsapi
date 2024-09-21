# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Header
        class Model < Meta::Base::Model
          include Extensions

          delegate_missing_to :schema

          ##
          # :attr: collection_format
          # The collection format of a header whose values are arrays. Possible values are:
          #
          # - <code>"csv"</code> -  comma separated values
          # - <code>"pipes"</code> - pipe separated values
          # - <code>"ssv"</code> - space separated values
          # - <code>"tsv"</code> - tab separated values
          #
          # Applies to \OpenAPI 2.0.
          attribute :collection_format, values: %w[csv pipes ssv tsv]

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
          attribute :schema, read_only: true

          def initialize(keywords = {})
            raise ArgumentError, "type can't be object" if keywords[:type] == 'object'

            keywords = keywords.dup
            super(
              keywords.extract!(
                :collection_format, :deprecated, :description, :examples, :openapi_extensions
              )
            )
            add_example(value: keywords.delete(:example)) if keywords.key?(:example)

            @schema = Schema.new(keywords)
          end

          # Returns a hash representing the \OpenAPI header object.
          def to_openapi(version)
            version = OpenAPI::Version.from(version)

            with_openapi_extensions(
              if version.major == 2
                schema.to_openapi(version).merge(
                  collection_format: (collection_format if array?),
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
