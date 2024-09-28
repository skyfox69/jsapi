# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON array.
    class Array < Value
      def initialize(values, schema, definitions, context: nil)
        super(schema)
        @json_values = Array(values).map do |value|
          JSON.wrap(value, schema.items, definitions, context: context)
        end
      end

      # Returns true if it contains no elements, false otherwise.
      def empty?
        @json_values.empty?
      end

      def inspect # :nodoc:
        "#<#{self.class.name} [#{@json_values.map(&:inspect).join(', ')}]>"
      end

      def validate(errors) # :nodoc:
        return false unless super

        @json_values.map { |element| element.validate(errors) }.all?
      end

      def value
        @value ||= @json_values.map(&:value)
      end
    end
  end
end
