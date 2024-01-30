# frozen_string_literal: true

module Jsapi
  module DOM
    class Number < BaseObject
      def initialize(value, schema)
        super(schema)
        @value = value
      end

      def cast
        @cast = @value.to_f
      end
    end
  end
end
