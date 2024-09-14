# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON object.
    class Object < Value
      include Model::Nestable

      attr_reader :raw_additional_attributes, :raw_attributes

      def initialize(attributes, schema, definitions)
        schema = schema.resolve_schema(attributes, definitions, context: :request)
        properties = schema.resolve_properties(definitions, context: :request)

        @raw_attributes = properties.transform_values do |property|
          JSON.wrap(attributes[property.name], property.schema, definitions)
        end

        @raw_additional_attributes =
          if (additional_properties = schema.additional_properties)
            additional_properties_schema = additional_properties.resolve(definitions)
            additional_attributes = attributes.except(*properties.keys)

            if additional_attributes.respond_to?(:permit)
              additional_attributes = additional_attributes.permit(*additional_attributes.keys)
            end

            additional_attributes.to_h.transform_values do |value|
              JSON.wrap(value, additional_properties_schema, definitions)
            end
          end || {}

        super(schema)
      end

      # Returns true if all attributes are empty, false otherwise.
      def empty?
        @raw_attributes.values.all?(&:empty?)
      end

      # Returns a model to read attributes by.
      def model
        @model ||= (schema.model || Model::Base).new(self)
      end

      alias value model

      # See Value#validate
      def validate(errors)
        return false unless super

        validate_attributes(errors)
      end
    end
  end
end
