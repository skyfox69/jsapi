# frozen_string_literal: true

module Jsapi
  module DOM
    class Array < BaseObject
      def initialize(array, schema, definitions)
        super(schema)
        @array = Array(array).map do |item|
          DOM.wrap(item, schema.items, definitions)
        end
      end

      def empty?
        @array.empty?
      end

      def validate(errors)
        return false unless super

        @array.map { |item| item.validate(errors) }.all?
      end

      def value
        @value ||= @array.map(&:value)
      end
    end
  end
end
