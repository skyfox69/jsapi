# frozen_string_literal: true

module Jsapi
  module Model
    module Validators
      class Enum
        def initialize(enum)
          raise ArgumentError, "invalid enum: #{enum}" unless enum.respond_to?(:include?)

          @enum = enum
        end

        def validate(value, errors)
          errors.add(:inclusion) unless @enum.include?(value)
        end
      end
    end
  end
end
