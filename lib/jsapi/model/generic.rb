# frozen_string_literal: true

module Jsapi
  module Model
    class Generic
      def initialize(**keywords)
        @keywords = keywords
        @children = {}
      end

      def add_child(name, **keywords)
        @children[name] = Generic.new(**keywords)
      end

      def to_openapi
        @keywords
          .merge(@children.transform_values(&:to_openapi))
          .transform_keys { |key| key.to_s.camelize(:lower).to_sym }
      end
    end
  end
end
