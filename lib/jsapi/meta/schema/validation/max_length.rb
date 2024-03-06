# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MaxLength < Base
          def initialize(value)
            raise ArgumentError, "invalid max length: #{value}" unless value.respond_to?(:<=)

            super
          end

          def validate(object)
            object.errors.add(:too_long, count: value) unless object.value.to_s.length <= value
          end
        end
      end
    end
  end
end
