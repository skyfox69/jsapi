# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class Enum < Base
          def initialize(value)
            raise ArgumentError, "invalid enum: #{value}" unless value.respond_to?(:include?)

            super
          end

          def validate(object)
            object.errors.add(:inclusion) unless value.include?(object.value)
          end
        end
      end
    end
  end
end
