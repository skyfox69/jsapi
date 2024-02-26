# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Numeric < Base
        json_schema_validation(
          :exclusive_maximum,
          :exclusive_minimum,
          :maximum,
          :minimum,
          :multiple_of
        )

        private

        def json_schema_options
          super.merge(
            exclusiveMinimum: exclusive_minimum,
            minimum: minimum,
            exclusiveMaximum: exclusive_maximum,
            maximum: maximum,
            multipleOf: multiple_of
          ).compact
        end
      end
    end
  end
end
