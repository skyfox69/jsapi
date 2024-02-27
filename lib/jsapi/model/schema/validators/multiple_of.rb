# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validators
        class MultipleOf
          def initialize(multiple_of)
            unless multiple_of.respond_to?(:%)
              raise ArgumentError, "invalid multiple of: #{multiple_of}"
            end

            @multiple_of = multiple_of
          end

          def validate(object)
            object.errors.add(:invalid) unless (object.value % @multiple_of).zero?
          end
        end
      end
    end
  end
end
