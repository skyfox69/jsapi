# frozen_string_literal: true

module Jsapi
  module DOM
    # Represents +true+ or +false+.
    class Boolean < Value
      TRUTHY_VALUES = [true, 'True', 'true'].freeze

      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = value.in?(TRUTHY_VALUES)
      end
    end
  end
end
