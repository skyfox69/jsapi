# frozen_string_literal: true

module Jsapi
  module DOM
    class Null < BaseObject
      def null?
        true
      end

      def cast
        nil
      end

      def empty?
        true
      end
    end
  end
end
