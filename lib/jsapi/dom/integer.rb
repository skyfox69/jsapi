# frozen_string_literal: true

module Jsapi
  module DOM
    class Integer < BaseObject
      def initialize(value, schema)
        super(schema)
        @value = value
      end

      def cast
        @cast = @value.to_i
      end
    end
  end
end
