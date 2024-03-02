# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validation
        class Maximum < Base
          attr_reader :exclusive

          def initialize(value, exclusive: false)
            if exclusive
              raise ArgumentError, "invalid exclusive maximum: #{value}" unless value.respond_to?(:<)
            else
              raise ArgumentError, "invalid maximum: #{value}" unless value.respond_to?(:<=)
            end

            super(value)
            @exclusive = exclusive
          end

          def validate(object)
            if exclusive
              object.errors.add(:less_than, count: value) unless object.value < value
            else
              object.errors.add(:less_than_or_equal_to, count: value) unless object.value <= value
            end
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
