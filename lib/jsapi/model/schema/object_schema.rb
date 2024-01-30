# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class ObjectSchema < Base
        def initialize(**options)
          super(**options.merge(type: 'object'))
          @properties = {}
        end

        def add_property(name, **options)
          @properties[name.to_s] = Property.new(name, **options)
        end

        def properties(definitions = nil)
          all_of.map do |schema|
            schema = schema.resolve(definitions) if definitions.present?
            schema.properties(definitions)
          end.reduce({}, &:merge).merge(@properties)
        end

        def to_json_schema(*)
          super.merge(
            properties: @properties.transform_values(&:to_json_schema),
            required: @properties.values.select(&:required?).map(&:name)
          )
        end

        def to_openapi_schema
          super.merge(
            properties: @properties.transform_values(&:to_openapi_schema),
            required: @properties.values.select(&:required?).map(&:name)
          )
        end
      end
    end
  end
end
