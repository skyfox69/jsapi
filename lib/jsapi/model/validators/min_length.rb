# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class MinLength
        def initialize(min_length)
          unless min_length.respond_to?(:<)
            raise ArgumentError, "invalid min length: #{min_length}"
          end

          @min_length = min_length
        end

        def validate(object)
          if object.value.to_s.length < @min_length
            object.errors.add(:too_short, count: @min_length)
          end
        end
      end
    end
  end
end
