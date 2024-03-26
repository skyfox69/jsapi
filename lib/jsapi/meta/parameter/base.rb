# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      class Base
        attr_accessor :description, :name
        attr_reader :location, :schema
        attr_writer :deprecated

        include Examples

        def initialize(name, **options)
          raise ArgumentError, "parameter name can't be blank" if name.blank?

          @name = name.to_s
          @location = options[:in] || 'query'
          @description = options[:description]
          @deprecated = options[:deprecated] == true
          @schema = Schema.new(**options.except(:deprecated, :description, :example, :in))

          add_example(value: options[:example]) if options.key?(:example)
        end

        # Returns true if and only if empty values can be passed
        # (see OpenAPI Specifications 2.0 and 3.x).
        def allow_empty_value?
          schema.existence <= Existence::ALLOW_EMPTY && location != 'path'
        end

        # Returns true if and only if the parameter is deprecated
        # (see OpenAPI Specifications 2.0 and 3.x).
        def deprecated?
          @deprecated == true
        end

        # Returns true if and only if the parameter is required as specified
        # by JSON Schema.
        def required?
          schema.existence > Existence::ALLOW_OMITTED || location == 'path'
        end

        def resolve(*)
          self
        end

        # Returns the OpenAPI parameter objects as an array of hashes.
        def to_openapi_parameters(version, definitions)
          version = OpenAPI::Version.from(version)
          schema = self.schema.resolve(definitions)

          if schema.object?
            explode_object_parameter(
              name,
              schema,
              version,
              definitions,
              required: required?,
              deprecated: deprecated?
            )
          else
            parameter_name = schema.array? ? "#{name}[]" : name
            [
              if version.major == 2
                {
                  name: parameter_name,
                  in: location,
                  description: description,
                  required: required?.presence,
                  allowEmptyValue: allow_empty_value?.presence,
                  collectionFormat: ('multi' if schema.array?)
                }.merge(schema.to_openapi_schema(version))
              else
                {
                  name: parameter_name,
                  in: location,
                  description: description,
                  required: required?.presence,
                  allowEmptyValue: allow_empty_value?.presence,
                  deprecated: deprecated?.presence,
                  schema: schema.to_openapi_schema(version),
                  examples: openapi_examples.presence

                  # NOTE: collectionFormat is replaced by style and explode.
                  #       The default values for query parameters are:
                  #       - style: 'form'
                  #       - explode: true
                }
              end.compact
            ]
          end
        end

        private

        def explode_object_parameter(name, schema, version, definitions, **options)
          schema.properties(definitions).values.flat_map do |property|
            property_schema = property.schema.resolve(definitions)
            parameter_name = "#{name}[#{property.name}]"

            required = (property.required? && options[:required]).presence
            deprecated = (property.deprecated? || options[:deprecated]).presence

            if property_schema.object?
              explode_object_parameter(
                parameter_name,
                property_schema,
                version,
                definitions,
                required: required,
                deprecated: deprecated
              )
            else
              parameter_name = "#{parameter_name}[]" if property_schema.array?
              description = property_schema.description
              allow_empty_value = property.schema.existence <= Existence::ALLOW_EMPTY
              [
                if version.major == 2
                  {
                    name: parameter_name,
                    in: location,
                    description: description,
                    required: required,
                    allowEmptyValue: allow_empty_value.presence,
                    collectionFormat: ('multi' if property_schema.array?)
                  }.merge(property_schema.to_openapi_schema(version))
                else
                  {
                    name: parameter_name,
                    in: location,
                    description: description,
                    required: required,
                    allowEmptyValue: allow_empty_value.presence,
                    deprecated: deprecated,
                    schema: property_schema.to_openapi_schema(version),
                    examples: property_schema.examples.presence
                  }
                end.compact
              ]
            end
          end
        end
      end
    end
  end
end
