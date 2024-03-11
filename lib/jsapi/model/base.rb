# frozen_string_literal: true

module Jsapi
  module Model
    class Base
      include Attributes
      include Validations

      def initialize(nested)
        @nested = nested
      end

      def ==(other)
        super || (
          self.class == other.class &&
          attributes == other.attributes
        )
      end

      def inspect
        [
          "#<#{self.class.name} ",
          attributes.map do |name, value|
            if value.is_a?(Base)
              # Call #inspect recursively
              value = value.inspect
            elsif value.is_a?(String)
              # Quote strings
              value = "'#{value}'"
            elsif value.nil?
              value = 'nil'
            end
            "#{name}: #{value}"
          end.join(', '),
          '>'
        ].join
      end

      private

      attr_reader :nested
    end
  end
end
