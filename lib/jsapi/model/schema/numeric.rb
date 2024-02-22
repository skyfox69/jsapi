# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Numeric < Base
        attr_reader :exclusive_maximum, :exclusive_minimum, :maximum, :minimum

        def exclusive_maximum=(value)
          set_json_schema_validation(:exclusive_maximum, value)
        end

        def exclusive_minimum=(value)
          set_json_schema_validation(:exclusive_minimum, value)
        end

        def maximum=(value)
          set_json_schema_validation(:maximum, value)
        end

        def minimum=(value)
          set_json_schema_validation(:minimum, value)
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
