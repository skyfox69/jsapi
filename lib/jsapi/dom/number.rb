# frozen_string_literal: true

module Jsapi
  module DOM
    class Number < BaseObject
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = schema.convert(value.to_f)
      end
    end
  end
end
