# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON string.
    class String < Value
      attr_reader :value

      def initialize(value, schema)
        super(schema)

        @value =
          begin
            case schema.format
            when 'date'
              value.to_date
            when 'date-time'
              value.to_datetime
            when 'duration'
              ActiveSupport::Duration.parse(value)
            else
              value.to_s
            end
          rescue StandardError => e
            @error = e
            value
          end
        @value = schema.convert(@value) unless defined? @error
      end

      def empty? # :nodoc:
        value.blank?
      end

      def validate(errors) # :nodoc:
        return super unless defined? @error

        errors.add(:base, :invalid)
        false
      end
    end
  end
end
