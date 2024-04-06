# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Array < Base
        attr_reader :items

        def initialize(**options)
          super(**options.merge(type: 'array'))
        end

        def items=(options = {})
          @items = Schema.new(**options)
        end

        def max_items=(value)
          add_validation('max_items', Validation::MaxItems.new(value))
        end

        def min_items=(value)
          add_validation('min_items', Validation::MinItems.new(value))
        end

        def to_json_schema
          super.merge(items: items&.to_json_schema || {})
        end

        def to_openapi_schema(version)
          super.merge(items: items&.to_openapi_schema(version) || {})
        end
      end
    end
  end
end
