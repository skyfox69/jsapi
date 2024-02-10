# frozen_string_literal: true

module Jsapi
  module Model
    class Existence
      include Comparable

      attr_reader :level

      def initialize(level)
        @level = level
      end

      # The parameter or property can be omitted, corresponds to the opposite
      # of +required+ as specified by JSON Schema.
      ALLOW_OMITTED = new(1)

      # The parameter or property value can be +nil+, corresponds to
      # +nullable: true+ as specified by JSON Schema.
      ALLOW_NIL = new(2)

      # The parameter or property value must respond to +nil?+ with +false+.
      ALLOW_EMPTY = new(3)

      # The parameter or property value must respond to +present?+ with +true+
      # or must be equal to +false+.
      PRESENT = new(4)

      def self.from(value)
        return value if value.is_a?(Existence)

        case value
        when :present, true
          PRESENT
        when :allow_empty
          ALLOW_EMPTY
        when :allow_nil, :allow_null
          ALLOW_NIL
        when :allow_omitted, false, nil
          ALLOW_OMITTED
        else
          raise ArgumentError, "invalid existence: #{value}"
        end
      end

      def ==(other)
        other.is_a?(Existence) && level == other.level
      end

      def <=>(other)
        level <=> other.level
      end
    end
  end
end
