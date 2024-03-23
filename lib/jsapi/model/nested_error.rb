# frozen_string_literal: true

module Jsapi
  module Model
    # Wraps an error related to a nested model.
    class NestedError
      attr_reader :attribute, :error

      delegate_missing_to :error

      def initialize(attribute, error)
        @attribute = attribute
        @error = error
      end

      def ==(other) # :nodoc:
        other.is_a?(self.class) &&
          @attribute == other.attribute &&
          @error == other.error
      end

      # Like <code>ActiveModel::Error#full_message</code>.
      def full_message
        base? ? "'#{attribute}' #{message}" : "'#{attribute}.#{message[1..]}"
      end

      # Like <code>ActiveModel::Error#match?</code>.
      def match?(attribute, type = nil, **options)
        return false if self.attribute != attribute
        return true if type.nil? && options.empty?

        @error.match?(:base, type, **options)
      end

      # Like <code>ActiveModel::Error#message</code>.
      def message
        base? ? @error.message : "'#{@error.attribute}' #{@error.message}".rstrip
      end

      # Like <code>ActiveModel::Error#strict_match?</code>.
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
