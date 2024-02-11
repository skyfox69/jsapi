# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class MinLength
        def initialize(min_length)
          raise ArgumentError, "invalid min length: #{min_length}" unless min_length.respond_to?(:<)

          @min_length = min_length
        end

        def validate(value, errors)
          errors.add(:too_short, count: @min_length) if value.to_s.length < @min_length
        end
      end
    end
  end
end
