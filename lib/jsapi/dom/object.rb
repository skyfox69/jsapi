# frozen_string_literal: true

module Jsapi
  module DOM
    class Object < BaseObject
      def initialize(attributes, schema, definitions)
        super(schema)

        @attributes = schema.properties(definitions).transform_values do |property|
          DOM.wrap(attributes[property.name], property.schema, definitions)
        end
      end

      def [](key)
        @attributes[key&.to_s].value
      end

      def attributes
        @attributes.transform_values(&:value)
      end

      def empty?
        @attributes.values.all?(&:empty?)
      end

      def method_missing(*args)
        name = args.first.to_s
        @attributes.key?(name) ? self[name] : super
      end

      def respond_to_missing?(param1, _param2)
        @attributes.key?(param1.to_s) ? true : super
      end

      def value
        self
      end

      def _validate
        super
        return if invalid?

        @attributes.each do |key, value|
          next if value&.valid?

          value.errors.each do |error|
            errors << AttributeError.new(key, error)
          end
        end
      end
    end
  end
end
