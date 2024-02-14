# frozen_string_literal: true

module Jsapi
  module DOM
    class Integer < BaseObject
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = value.to_i
      end
    end
  end
end
