# frozen_string_literal: true

module Jsapi
  module DOM
    class Boolean < BaseObject
      def initialize(value, schema)
        super(schema)
        @value = value
      end

      def cast
        @cast ||=
          case @value
          when true, 'true'
            true
          when false, 'false'
            false
          end
      end
    end
  end
end
