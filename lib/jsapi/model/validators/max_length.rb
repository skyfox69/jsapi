# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class MaxLength
        def initialize(max_length)
          raise ArgumentError, "invalid max length: #{max_length}" unless max_length.respond_to?(:>)

          @max_length = max_length
        end

        def validate(value, errors)
          errors.add(:too_long, count: @max_length) if value.to_s.length > @max_length
        end
      end
    end
  end
end
