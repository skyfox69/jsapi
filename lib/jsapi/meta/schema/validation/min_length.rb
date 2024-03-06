# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MinLength < Base
          def initialize(value)
            raise ArgumentError, "invalid min length: #{value}" unless value.respond_to?(:>=)

            super
          end

          def validate(object)
            object.errors.add(:too_short, count: value) unless object.value.to_s.length >= value
          end
        end
      end
    end
  end
end
