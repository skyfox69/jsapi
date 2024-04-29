# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Base < Meta::Base
        ##
        # :attr: description
        # The optional description of the response.
        attribute :description, String

        ##
        # :attr_reader: examples
        # The optional examples.
        attribute :examples, { String => Example }, default_key: 'default'

        ##
        # :attr:
        # The locale used when rendering a response.
        attribute :locale, Symbol

        ##
        # :attr_reader: schema
        # The Schema of the parameter.
        attribute :schema, writer: false

        delegate_missing_to :schema

        # Creates a new response.
        def initialize(keywords = {})
          keywords = keywords.dup
          super(keywords.extract!(:description, :examples, :locale))

          add_example(value: keywords.delete(:example)) if keywords.key?(:example)

          @schema = Schema.new(**keywords)
        end

        # Returns itself.
        def resolve(*)
          self
        end

        # Returns a hash representing the \OpenAPI response object.
        def to_openapi_response(version)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            {
              description: description,
              schema: schema.to_openapi_schema(version),
              examples: (
                if examples.present?
                  { 'application/json' => examples.values.first.value }
                end
              )
            }
          else
            {
              description: description,
              content: {
                'application/json' => {
                  schema: schema.to_openapi_schema(version),
                  examples: examples&.transform_values(&:to_openapi_example)
                }.compact
              }
            }
          end.compact
        end
      end
    end
  end
end
