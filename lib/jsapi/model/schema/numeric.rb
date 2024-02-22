# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Numeric < Base
        json_schema_validation :exclusive_maximum, :exclusive_minimum, :maximum, :minimum

        private

        def json_schema_options
          super.merge(
            exclusiveMinimum: exclusive_minimum,
            minimum: minimum,
            exclusiveMaximum: exclusive_maximum,
            maximum: maximum
          ).compact
        end
      end
    end
  end
end
