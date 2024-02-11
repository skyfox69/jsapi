# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class Maximum
        def initialize(maximum)
          raise ArgumentError, "invalid maximum: #{maximum}" unless maximum.respond_to?(:>)

          @maximum = maximum
        end

        def validate(value, errors)
          errors.add(:less_than_or_equal_to, count: @maximum) if value > @maximum
        end
      end
    end
  end
end
