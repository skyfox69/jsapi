# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      module Validators
        class Enum
          def initialize(enum)
            raise ArgumentError, "invalid enum: #{enum}" unless enum.respond_to?(:include?)

            @enum = enum
          end

          def validate(object)
            object.errors.add(:inclusion) unless @enum.include?(object.value)
          end
        end
      end
    end
  end
end
