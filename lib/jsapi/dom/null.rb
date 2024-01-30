# frozen_string_literal: true

module Jsapi
  module DOM
    class Null < BaseObject
      def _validate
        errors.add(:blank) unless schema.nullable?
      end

      def cast
        nil
      end
    end
  end
end
