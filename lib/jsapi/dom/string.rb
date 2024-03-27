# frozen_string_literal: true

module Jsapi
  module DOM
    # Represents a JSON string.
    class String < Value
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value = schema.convert(
          case schema.format
          when 'date'
            value.to_date
          when 'date-time'
            value.to_datetime
          else
            value.to_s
          end
        )
      end

      # See Value#empty?.
      def empty?
        value.blank?
      end
    end
  end
end
