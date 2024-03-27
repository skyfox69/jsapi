# frozen_string_literal: true

module Jsapi
  module DOM
    class Object < BaseObject
      include Model::Nestable

      attr_reader :raw_attributes

      def initialize(attributes, schema, definitions)
        super(schema)

        @raw_attributes = schema.properties(definitions).transform_values do |property|
          DOM.wrap(attributes[property.name], property.schema, definitions)
        end
      end

      def empty?
        @raw_attributes.values.all?(&:empty?)
      end

      def inspect # :nodoc:
        "#<#{self.class.name} " \
        "#{@raw_attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ') }>"
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
