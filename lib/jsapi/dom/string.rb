# frozen_string_literal: true

module Jsapi
  module DOM
    class String < BaseObject
      attr_reader :value

      def initialize(value, schema)
        super(schema)
        @value =
          case schema.format
          when 'date'
            value.to_date
          when 'date-time'
            value.to_datetime
          else
            value.to_s
          end
      end

      def empty?
        value.blank?
      end
    end
  end
end
