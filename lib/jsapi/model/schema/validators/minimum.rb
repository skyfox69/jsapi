# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validators
        class Minimum
          def initialize(minimum)
            raise ArgumentError, "invalid minimum: #{minimum}" unless minimum.respond_to?(:<)

            @minimum = minimum
          end

          def validate(object)
            if object.value < @minimum
              object.errors.add(:greater_than_or_equal_to, count: @minimum)
            end
          end
        end
      end
    end
  end
end
