# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validation
        class MinItems < Base
          def initialize(value)
            raise ArgumentError, "invalid min items: #{value}" unless value.respond_to?(:>=)

            super
          end

          def validate(object)
            object.errors.add(:invalid) unless object.value.size >= value
          end
        end
      end
    end
  end
end
