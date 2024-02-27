# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validators
        class Pattern
          def initialize(pattern)
            raise ArgumentError, "invalid pattern: #{pattern}" unless pattern.is_a?(Regexp)

            @pattern = pattern
          end

          def validate(object)
            object.errors.add(:invalid) unless object.value.to_s.match?(@pattern)
          end
        end
      end
    end
  end
end
