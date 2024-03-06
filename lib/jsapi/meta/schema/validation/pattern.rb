# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class Pattern < Base
          def initialize(value)
            raise ArgumentError, "invalid pattern: #{value}" unless value.is_a?(Regexp)

            super
          end

          def validate(object)
            object.errors.add(:invalid) unless object.value.to_s.match?(value)
          end

          def to_json_schema_validation
            { pattern: value.source }
          end
        end
      end
    end
  end
end
