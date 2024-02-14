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

      def errors
        @errors ||= @ary.flat_map(&:errors)
      end

      def value
        @value ||= @ary.map(&:value)
      end
    end
  end
end
