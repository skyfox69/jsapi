# frozen_string_literal: true

module Jsapi
  module JSON
    # Represents a JSON value.
    #
    # Subclasses of Value must provide a +value+ method returning the outside
    # representation of the JSON value.
    class Value
      attr_reader :schema

      def initialize(schema)
        @schema = schema
      end

      # Used by #validate to test whether or not it is empty.
      # Returns +false+ by default.
      def empty?
        false
      end

      def inspect  # :nodoc:
        "#<#{self.class} #{value.inspect}>"
      end

      # Used by #validate to test whether or not it is +null+.
      # Returns +false+ by default.
      def null?
        false
      end

      # Validates it against #schema. Returns +true+ if it is valid, +false+
      # otherwise. Detected errors are added to +errors+.
      def validate(errors)
        unless schema.existence.reach?(self)
          errors.add(:base, :blank)
          return false
        end
        return true if null?

        schema.validations.each_value.map do |validation|
          validation.validate(value, errors)
        end.all?
      end
    end
  end
end
