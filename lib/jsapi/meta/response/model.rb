# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Model < Base
        ##
        # :attr: description
        # The optional description of the response.
        attribute :description, String

        ##
        # :attr: examples
        # The optional examples.
        attribute :examples, { String => Example }, default_key: 'default'

        ##
        # :attr: links
        # The optional OpenAPI::Link objects.
        attribute :links, { String => OpenAPI::Link }

        ##
        # :attr: locale
        # The locale used when rendering a response.
        attribute :locale, Symbol

        ##
        # :attr_reader: schema
        # The Schema of the response.
        attribute :schema, writer: false

        delegate_missing_to :schema

        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:description, :examples, :locale))

          add_example(value: keywords.delete(:example)) if keywords.key?(:example)
          keywords[:ref] = keywords.delete(:schema) if keywords.key?(:schema)

          @schema = Schema.new(**keywords)
        end

        # Returns a hash representing the \OpenAPI response object.
        def to_openapi(version, definitions)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            {
              description: description,
              schema: schema.to_openapi(version),
              examples: (
                if (example = examples&.values&.first).present?
                  { 'application/json' => example.resolve(definitions).value }
                end
              )
            }
          else
            {
              description: description,
              content: {
                'application/json' => {
                  schema: schema.to_openapi(version),
                  examples: examples&.transform_values(&:to_openapi)
                }.compact
              },
              links: links&.transform_values(&:to_openapi)
            }
          end.compact
        end
      end
    end
  end
end
