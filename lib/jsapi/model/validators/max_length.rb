# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class MaxLength
        def initialize(max_length)
          unless max_length.respond_to?(:>)
            raise ArgumentError, "invalid max length: #{max_length}"
          end

          @max_length = max_length
        end

        def validate(object)
          if object.value.to_s.length > @max_length
            object.errors.add(:too_long, count: @max_length)
          end
        end
      end
    end
  end
end
