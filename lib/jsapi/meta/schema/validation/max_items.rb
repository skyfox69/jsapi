# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MaxItems < Base
          def initialize(value)
            unless value.respond_to?(:<=)
              raise ArgumentError, "invalid max items: #{value}"
            end

            super
          end

          def validate(value, errors)
            return true if value.size <= self.value

            errors.add(:base, :invalid)
            false
          end
        end
      end
    end
  end
end
