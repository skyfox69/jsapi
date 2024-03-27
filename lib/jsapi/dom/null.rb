# frozen_string_literal: true

module Jsapi
  module DOM
    # Represents +null+.
    class Null < Value
      # Returns allways +true+.
      def empty?
        true
      end

      def inspect # :nodoc:
        "#<#{self.class}>"
      end

      # Returns allways +true+.
      def null?
        true
      end

      def value
        nil
      end
    end
  end
end
