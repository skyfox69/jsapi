# frozen_string_literal: true

module Jsapi
  module Meta
    module Response
      class Base
        attr_accessor :description, :locale
        attr_reader :schema

        include Examples

        def initialize(**options)
          @description = options[:description]
          @locale = options[:locale]
          @schema = Schema.new(**options.except(:description, :example, :locale))

          add_example(value: options[:example]) if options.key?(:example)
        end

        def resolve(*)
          self
        end

        # Returns the OpenAPI response object as a +Hash+.
        def to_openapi_response(version)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            {
              description: description,
              schema: schema.to_openapi_schema(version),
              examples: (
                if examples.any?
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
                  examples: openapi_examples.presence
                }.compact
              }
            }
          end.compact
        end
      end
    end
  end
end
