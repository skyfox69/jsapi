# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Numeric < Base
        attr_reader :exclusive_maximum, :exclusive_minimum, :maximum, :minimum

        def exclusive_maximum=(value)
          register_validator(:exclusive_maximum, @exclusive_maximum = value)
        end

        def exclusive_minimum=(value)
          register_validator(:exclusive_minimum, @exclusive_minimum = value)
        end

        def maximum=(value)
          register_validator(:maximum, @maximum = value)
        end

        def minimum=(value)
          register_validator(:minimum, @minimum = value)
        end

        private

        def json_schema_options
          super.merge(
            exclusiveMinimum: exclusive_minimum,
            minimum: minimum,
            exclusiveMaximum: exclusive_maximum,
            maximum: maximum
          )
        end
      end
    end
  end
end
