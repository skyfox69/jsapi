# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MaxItems < Base
          def initialize(value)
            raise ArgumentError, "invalid max items: #{value}" unless value.respond_to?(:<=)

            super
          end

          def validate(object)
            object.errors.add(:invalid) unless object.value.size <= value
          end
        end
      end
    end
  end
end
