# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MultipleOf < Base
          def initialize(value)
            raise ArgumentError, "invalid multiple of: #{value.inspect}" unless value.respond_to?(:%)

            super
          end

          def validate(value, errors)
            return true if (value % self.value).zero?

            errors.add(:base, :invalid)
            false
          end
        end
      end
    end
  end
end
