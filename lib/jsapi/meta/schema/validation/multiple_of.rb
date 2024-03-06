# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class MultipleOf < Base
          def initialize(value)
            raise ArgumentError, "invalid multiple of: #{value}" unless value.respond_to?(:%)

            super
          end

          def validate(object)
            object.errors.add(:invalid) unless (object.value % value).zero?
          end
        end
      end
    end
  end
end
