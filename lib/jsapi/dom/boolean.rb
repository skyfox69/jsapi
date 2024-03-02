# frozen_string_literal: true

module Jsapi
  module DOM
    class Boolean < BaseObject
      TRUTHY_VALUES = [true, 'True', 'true'].freeze

      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = value.in?(TRUTHY_VALUES)
      end
    end
  end
end
