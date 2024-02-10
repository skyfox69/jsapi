# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Object < Base
        attr_reader :all_of

        def initialize(**options)
          super(**options.merge(type: 'object'))
          @all_of = []
          @properties = {}
        end

        def add_all_of(schema_name)
          @all_of << Reference.new(schema: schema_name) if schema_name.present?
        end

        def add_property(name, **options)
          @properties[name.to_s] = Property.new(name, **options)
        end

        def properties(definitions = nil)
          # TODO: Prevent circular references
          all_of.map do |schema|
            schema = schema.resolve(definitions) if definitions.present?
            schema.properties(definitions)
          end.reduce({}, &:merge).merge(@properties)
        end

        def to_json_schema(*)
          super.merge(
            allOf: @all_of.map(&:to_json_schema).presence,
            properties: @properties.transform_values(&:to_json_schema),
            required: @properties.values.select(&:required?).map(&:name)
          ).compact
        end

        def to_openapi_schema
          super.merge(
            allOf: @all_of.map(&:to_openapi_schema).presence,
            properties: @properties.transform_values(&:to_openapi_schema),
            required: @properties.values.select(&:required?).map(&:name)
          ).compact
        end
      end
    end
  end
end
