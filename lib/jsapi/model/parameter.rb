# frozen_string_literal: true

module Jsapi
  module Model
    class Parameter
      attr_accessor :description, :example, :name
      attr_reader :location, :schema
      attr_writer :deprecated

      def initialize(name, **options)
        raise ArgumentError, "parameter name can't be blank" if name.blank?

        @name = name.to_s
        @location = options[:in] || 'query'
        @description = options[:description]
        @deprecated = options[:deprecated] == true
        @example = options[:example]
        @schema = Schema.new(**options.except(:deprecated, :description, :example, :in))
      end

      def deprecated?
        @deprecated == true
      end

      # Returns +true+ if and only if the parameter is required as specified
      # by JSON Schema.
      def required?
        schema.existence > Existence::ALLOW_OMITTED || location == 'path'
      end

      def resolve(_definitions)
        self
      end

      # Returns the OpenAPI parameter objects as an array of hashes.
      def to_openapi_parameters(version, definitions)
        schema = self.schema.resolve(definitions)

        if schema.object?
          explode_object_parameter(name, schema, version, definitions)
        else
          parameter_name = schema.array? ? "#{name}[]" : name
          [
            if version == '2.0'
              {
                name: parameter_name,
                in: location,
                description: description,
                required: required?.presence,
                collectionFormat: ('multi' if schema.array?)
              }.merge(schema.to_openapi_schema(version))
            else
              {
                name: parameter_name,
                in: location,
                description: description,
                required: required?.presence,
                deprecated: deprecated?.presence,
                explode: (true if schema.array?),
                style: ('form' if schema.array?),
                schema: schema.to_openapi_schema(version),
                example: example
              }
            end.compact
          ]
        end
      end

      private

      def explode_object_parameter(name, schema, version, definitions)
        schema.properties(definitions).values.flat_map do |property|
          property_schema = property.schema.resolve(definitions)
          parameter_name = "#{name}[#{property.name}]"

          if property_schema.object?
            explode_object_parameter(parameter_name, property_schema, version, definitions)
          else
            parameter_name = "#{parameter_name}[]" if property_schema.array?
            [
              if version == '2.0'
                {
                  name: parameter_name,
                  in: location,
                  description: property_schema.description,
                  required: property.required?.presence, # TODO
                  collectionFormat: ('multi' if property_schema.array?)
                }.merge(property_schema.to_openapi_schema(version))
              else
                {
                  name: parameter_name,
                  in: location,
                  description: property_schema.description,
                  required: property.required?.presence, # TODO
                  explode: (true if property_schema.array?),
                  style: ('form' if property_schema.array?),
                  deprecated: deprecated?.presence, # TODO
                  schema: property_schema.to_openapi_schema(version),
                  example: property_schema.example
                }
              end.compact
            ]
          end
        end
      end
    end
  end
end
