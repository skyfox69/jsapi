# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class ExclusiveMaximum
        def initialize(exclusive_maximum)
          raise ArgumentError, "invalid exclusive maximum: #{exclusive_maximum}" unless exclusive_maximum.respond_to?(:>=)

          @exclusive_maximum = exclusive_maximum
        end

        def validate(value, errors)
          errors.add(:less_than, count: @exclusive_maximum) if value >= @exclusive_maximum
        end
      end
    end
  end
end
