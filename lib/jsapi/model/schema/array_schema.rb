# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class ArraySchema < Base
        attr_reader :items

        def initialize(**options)
          super(**options.merge(type: 'array'))
        end

        def items=(options)
          @items = Schema.new(**options)
        end

        def to_json_schema(*)
          super.merge(items: items&.to_json_schema || {})
        end

        def to_openapi_schema
          super.merge(items: items&.to_openapi_schema || {})
        end
      end
    end
  end
end
