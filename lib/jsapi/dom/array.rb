# frozen_string_literal: true

module Jsapi
  module DOM
    class Array < BaseObject
      def initialize(ary, schema)
        super(schema)
        @ary = Array(ary).map do |item|
          DOM.wrap(item, schema.items)
        end
      end

      def cast
        @cast ||= @ary.map(&:cast)
      end

      def errors
        @errors ||= @ary.flat_map(&:errors)
      end
    end
  end
end
