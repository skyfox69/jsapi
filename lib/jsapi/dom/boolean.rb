# frozen_string_literal: true

module Jsapi
  module DOM
    class Boolean < BaseObject
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value =
          case value
          when true, 'true'
            true
          when false, 'false'
            false
          end
      end
    end
  end
end
