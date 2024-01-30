# frozen_string_literal: true

module Jsapi
  module Validators
    class Pattern
      def initialize(pattern)
        raise ArgumentError, "Invalid pattern: #{pattern}" unless pattern.is_a?(Regexp)

        @pattern = pattern
      end

      def validate(value, errors)
        errors.add(:invalid) unless value.to_s.match?(@pattern)
      end
    end
  end
end
