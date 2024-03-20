# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Object < Base
        attr_accessor :model
        attr_reader :all_of

        def initialize(**options)
          @all_of = []
          @model = nil
          @properties = {}
          super(**options.merge(type: 'object'))
        end

        def add_all_of(name)
          @all_of << Reference.new(schema: name) if name.present?
        end

        def add_property(name, **options)
          @properties[name.to_s] = Property.new(name, **options)
        end

        def properties(definitions)
          merge_properties(definitions, [])
        end

        def to_json_schema
          super.merge(
            allOf: @all_of.map(&:to_json_schema).presence,
            properties: @properties.transform_values(&:to_json_schema),
            required: @properties.values.select(&:required?).map(&:name)
          ).compact
        end

        def to_openapi_schema(version)
          super.merge(
            allOf: @all_of.map do |schema|
              schema.to_openapi_schema(version)
            end.presence,
            properties: @properties.transform_values do |property|
              property.to_openapi_schema(version)
            end,
            required: @properties.values.select(&:required?).map(&:name)
          ).compact
        end

        protected

        def merge_properties(definitions, path)
          return @properties unless @all_of.any?

          {}.tap do |properties|
            @all_of.each do |reference|
              schema = reference.resolve(definitions)
              raise "circular reference: #{reference.reference}" if schema.in?(path)

              properties.merge!(schema.merge_properties(definitions, path + [self]))
            end
            properties.merge!(@properties)
          end
        end
      end
    end
  end
end
