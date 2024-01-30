# frozen_string_literal: true

module Jsapi
  module Validators
    class ExclusiveMinimum
      def initialize(exclusive_minimum)
        raise ArgumentError, "Invalid exclusive minimum: #{exclusive_minimum}" unless exclusive_minimum.respond_to?(:<=)

        @exclusive_minimum = exclusive_minimum
      end

      def validate(value, errors)
        errors.add(:greater_than, count: @exclusive_minimum) if value <= @exclusive_minimum
      end
    end
  end
end
