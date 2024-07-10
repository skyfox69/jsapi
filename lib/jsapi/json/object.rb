# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON object.
    class Object < Value
      include Model::Nestable

      attr_reader :raw_attributes

      def initialize(attributes, schema, definitions)
        # Select inherriting schema on polymorphism
        if (discriminator = schema.discriminator)
          schema = discriminator.resolve(attributes[discriminator.property_name], definitions)
        end
        # Wrap attribute values
        @raw_attributes =
          schema.resolve_properties(:write, definitions).transform_values do |property|
            JSON.wrap(attributes[property.name], property.schema, definitions)
          end

        super(schema)
      end

      # Returns true if all attributes are empty, false otherwise.
      def empty?
        @raw_attributes.values.all?(&:empty?)
      end

      def inspect # :nodoc:
        "#<#{self.class.name} " \
        "#{@raw_attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
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
