# frozen_string_literal: true

module Jsapi
  module Model
    # The base API model used to represent top-level parameters and nested object
    # parameters by default.
    class Base
      extend Naming

      include Attributes
      include Validations

      def initialize(nested)
        @nested = nested
      end

      def ==(other) # :nodoc:
        super || (
          self.class == other.class &&
          attributes == other.attributes
        )
      end

      def inspect # :nodoc:
        "#<#{self.class.name}#{' ' if attributes.any?}" \
        "#{attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
      end

      private

      attr_reader :nested
    end
  end
end
