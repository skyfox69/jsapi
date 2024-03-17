# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class Maximum < Base
          attr_reader :exclusive

          def initialize(value, exclusive: false)
            if exclusive
              raise ArgumentError, "invalid exclusive maximum: #{value.inspect}" unless value.respond_to?(:<)
            else
              raise ArgumentError, "invalid maximum: #{value.inspect}" unless value.respond_to?(:<=)
            end

            super(value)
            @exclusive = exclusive
          end

          def validate(value, errors)
            if exclusive
              return true if value < self.value

              errors.add(:base, :less_than, count: self.value)
            else
              return true if value <= self.value

              errors.add(:base, :less_than_or_equal_to, count: self.value)
            end
            false
          end

          def to_json_schema_validation
            return super unless exclusive

            { exclusiveMaximum: value }
          end

          def to_openapi_validation(version)
            return to_json_schema_validation if version == '3.1'
            return super unless exclusive

            { maximum: value, exclusiveMaximum: true }
          end
        end
      end
    end
  end
end
