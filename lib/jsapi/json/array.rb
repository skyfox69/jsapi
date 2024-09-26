# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON array.
    class Array < Value
      def initialize(elements, schema, definitions, context: nil)
        super(schema)
        @elements = Array(elements).map do |element|
          JSON.wrap(element, schema.items, definitions, context: context)
        end
      end

      # Returns true if it contains no elements, false otherwise.
      def empty?
        @elements.empty?
      end

      def inspect # :nodoc:
        "#<#{self.class.name} [#{@elements.map(&:inspect).join(', ')}]>"
      end

      def validate(errors) # :nodoc:
        return false unless super

        @elements.map { |element| element.validate(errors) }.all?
      end

      def value
        @value ||= @elements.map(&:value)
      end
    end
  end
end
