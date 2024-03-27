# frozen_string_literal: true

module Jsapi
  module DOM
    # Represents a JSON integer.
    class Integer < Value
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = schema.convert(value.to_i)
      end
    end
  end
end
