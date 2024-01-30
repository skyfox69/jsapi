# frozen_string_literal: true

module Jsapi
  module Controller
    class Response
      def initialize(object, schema, definitions)
        @object = object
        @definitions = definitions
        @schema = schema.resolve(definitions)
      end

      def serialize
        serialize_recursively(@object, @schema)
      end

      private

      def serialize_recursively(object, schema, path = nil)
        return if object.nil? && schema.nullable?
        raise "#{path || 'Response'} can't be nil" if object.nil?

        case schema.type
        when 'array'
          item_schema = schema.items.resolve(@definitions)
          Array(object).map { |item| serialize_recursively(item, item_schema, path) }
        when 'integer'
          object.to_i
        when 'number'
          object.to_f
        when 'object'
          return if object.blank? # {}

          schema.properties(@definitions).transform_values do |property|
            serialize_recursively(
              object.public_send(property.source || property.name),
              property.schema.resolve(@definitions),
              path.nil? ? property.name : "#{path}.#{property.name}"
            )
          end
        else
          object
        end
      end
    end
  end
end
