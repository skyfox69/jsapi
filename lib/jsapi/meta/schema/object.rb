# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Object < Base
        ##
        # :attr: all_of_references
        attribute :all_of_references, [Reference], default: []

        alias :all_of= :all_of_references=
        alias :add_all_of :add_all_of_reference

        ##
        # :attr: model
        # The model class to access nested object parameters by. The default
        # model class is Model::Base.
        attribute :model, Class, default: Model::Base

        ##
        # :attr: properties
        # The properties.
        attribute :properties, { String => Property }, writer: false, default: {}

        def add_property(name, keywords = {}) # :nodoc:
          (@properties ||= {})[name.to_s] = Property.new(name, **keywords)
        end

        def resolve_properties(definitions)
          merge_properties(definitions, [])
        end

        def to_json_schema # :nodoc:
          super.merge(
            allOf: all_of_references.map(&:to_json_schema).presence,
            properties: properties.transform_values(&:to_json_schema),
            required: properties.values.select(&:required?).map(&:name)
          ).compact
        end

        def to_openapi_schema(version) # :nodoc:
          super.merge(
            allOf: all_of_references.map do |schema|
              schema.to_openapi_schema(version)
            end.presence,
            properties: properties.transform_values do |property|
              property.to_openapi_schema(version)
            end,
            required: properties.values.select(&:required?).map(&:name)
          ).compact
        end

        protected

        def merge_properties(definitions, path)
          return properties unless all_of_references.present?

          {}.tap do |properties|
            all_of_references.each do |reference|
              schema = reference.resolve(definitions)
              raise "circular reference: #{reference.schema}" if schema.in?(path)

              properties.merge!(schema.merge_properties(definitions, path + [self]))
            end
            properties.merge!(self.properties)
          end
        end
      end
    end
  end
end
