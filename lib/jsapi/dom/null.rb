# frozen_string_literal: true

module Jsapi
  module DOM
    class Null < BaseObject
      def empty?
        true
      end

      def null?
        true
      end

      def value
        nil
      end
    end
  end
end
