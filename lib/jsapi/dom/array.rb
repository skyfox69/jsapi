# frozen_string_literal: true

module Jsapi
  module DOM
    class Array < BaseObject
      def initialize(ary, schema, definitions)
        super(schema)
        @ary = Array(ary).map do |item|
          DOM.wrap(item, schema.items, definitions)
        end
      end

      def empty?
        @ary.empty?
      end

      def value
        @value ||= @ary.map(&:value)
      end

      def _validate
        super
        return if invalid?

        @ary.each do |item|
          next if item.valid?

          item.errors.each { |error| errors << error }
        end
      end
    end
  end
end
