# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validators
        class ExclusiveMinimum
          def initialize(exclusive_minimum)
            unless exclusive_minimum.respond_to?(:<=)
              raise ArgumentError, "invalid exclusive minimum: #{exclusive_minimum}"
            end

            @exclusive_minimum = exclusive_minimum
          end

          def validate(object)
            if object.value <= @exclusive_minimum
              object.errors.add(:greater_than, count: @exclusive_minimum)
            end
          end
        end
      end
    end
  end
end
