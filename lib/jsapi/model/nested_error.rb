# frozen_string_literal: true

module Jsapi
  module Model
    class NestedError
      attr_reader :attribute, :error

      delegate_missing_to :error

      def initialize(attribute, error)
        @attribute = attribute
        @error = error
      end

      def ==(other)
        other.is_a?(self.class) &&
          @attribute == other.attribute &&
          @error == other.error
      end

      def full_message
        base? ? "'#{attribute}' #{message}" : "'#{attribute}.#{message[1..]}"
      end

      def match?(attribute, type = nil, **options)
        return false if self.attribute != attribute
        return true if type.nil? && options.empty?

        @error.match?(:base, type, **options)
      end

      def message
        base? ? @error.message : "'#{@error.attribute}' #{@error.message}".rstrip
      end

      def strict_match?(attribute, type = nil, **options)
        return false unless match?(attribute, type, **options)

        @error.strict_match?(:base, type, **options)
      end

      private

      def base?
        @error.attribute == :base
      end
    end
  end
end
