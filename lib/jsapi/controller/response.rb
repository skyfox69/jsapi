# frozen_string_literal: true

module Jsapi
  module Controller
    class Response
      def initialize(object, schema, definitions)
        @object = object
        @definitions = definitions
        @schema = schema.resolve(definitions)
      end

      def to_json(*)
        serialize(@object, @schema).to_json
      end

      private

      def serialize(object, schema, path = nil)
        return if object.nil? && schema.nullable?
        raise "#{path || 'response'} can't be nil" if object.nil?

        case schema.type
        when 'array'
          item_schema = schema.items.resolve(@definitions)
          Array(object).map { |item| serialize(item, item_schema, path) }
        when 'integer'
          schema.convert(object.to_i)
        when 'number'
          schema.convert(object.to_f)
        when 'object'
          return if object.blank? # {}

          schema.properties(@definitions).transform_values do |property|
            serialize(
              object.public_send(property.source || property.name),
              property.schema.resolve(@definitions),
              path.nil? ? property.name : "#{path}.#{property.name}"
            )
          end
        when 'string'
          schema.convert(
            case schema.format
            when 'date'
              object.to_date
            when 'date-time'
              object.to_datetime
            else
              object.to_s
            end
          )
        else
          object
        end
      end
    end
  end
end
