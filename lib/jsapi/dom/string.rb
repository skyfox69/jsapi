# frozen_string_literal: true

module Jsapi
  module DOM
    class String < BaseObject
      def initialize(str, schema)
        super(schema)
        @str = str.to_s
      end

      def cast
        @cast ||=
          case schema.format
          when 'date'
            @str.to_date
          when 'date-time'
            @str.to_datetime
          else
            @str
          end
      end
    end
  end
end
