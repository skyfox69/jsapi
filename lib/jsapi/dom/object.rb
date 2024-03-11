# frozen_string_literal: true

module Jsapi
  module DOM
    class Object < BaseObject
      include Model::Nestable

      def initialize(attributes, schema, definitions)
        super(schema)

        @attributes = schema.properties(definitions).transform_values do |property|
          DOM.wrap(attributes[property.name], property.schema, definitions)
        end
      end

      def empty?
        @attributes.values.all?(&:empty?)
      end

      def model
        @model ||= (schema.model || Model::Base).new(self)
      end

      alias value model

      def validate(errors)
        return false unless super

        validate_attributes(errors)
      end
    end
  end
end
