# frozen_string_literal: true

module Jsapi
  module DOM
    class Array < BaseObject
      def initialize(items, schema, definitions)
        super(schema)
        @items = Array(items).map do |item|
          DOM.wrap(item, schema.items, definitions)
        end
      end

      def empty?
        @items.empty?
      end

      def inspect # :nodoc:
        "#<#{self.class.name} [#{@items.map(&:inspect).join(', ')}]>"
      end

      def validate(errors)
        return false unless super

        @items.map { |item| item.validate(errors) }.all?
      end

      def value
        @value ||= @items.map(&:value)
      end
    end
  end
end
