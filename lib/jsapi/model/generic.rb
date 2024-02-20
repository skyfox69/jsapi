# frozen_string_literal: true

module Jsapi
  module Model
    class Generic
      def initialize(**keywords)
        @keywords = keywords
        @children = {}
      end

      def [](keyword)
        @keywords[keyword.to_sym]
      end

      def []=(keyword, value)
        @keywords[keyword.to_sym] = value
      end

      def add_child(name, **keywords)
        @children[name.to_sym] = Generic.new(**keywords)
      end

      def to_h
        @keywords
          .merge(@children.transform_values(&:to_h))
          .transform_keys { |key| key.to_s.camelize(:lower).to_sym }
      end
    end
  end
end
