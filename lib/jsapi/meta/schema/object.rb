# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Object < Base
        ##
        # :attr: additional_properties
        # The AdditionalProperties.
        attribute :additional_properties, AdditionalProperties

        ##
        # :attr: all_of_references
        attribute :all_of_references, [Reference], default: []

        alias :all_of= :all_of_references= # :nodoc:
        alias :add_all_of :add_all_of_reference

        ##
        # :attr: discriminator
        # The Discriminator.
        attribute :discriminator, Discriminator

        ##
        # :attr: model
        # The model class to access nested object parameters by. The default
        # model class is Model::Base.
        attribute :model, Class, default: Model::Base

        ##
        # :attr: properties
        # The properties.
        attribute :properties, { String => Property }, default: {}

        undef add_property

        def add_property(name, keywords = {}) # :nodoc:
          (@properties ||= {})[name.to_s] = Property.new(name, **keywords)
        end

        def resolve_properties(definitions, context: nil)
          properties = merge_properties(definitions, [])

          case context
          when :response
            properties.reject { |_k, v| v.write_only? }
          when :request
            properties.reject { |_k, v| v.read_only? }
          else
            properties
          end
        end

        # Resolves the schema within +context+.
        #
        # Raises a +RuntimeError+ when the schema couldn't be resolved.
        def resolve_schema(object, definitions, context: nil)
          return self if discriminator.nil?

          properties = resolve_properties(definitions, context: context)

          property = properties[discriminator.property_name]
          raise InvalidValueError.new('discriminator property',
                                      discriminator.property_name,
                                      valid_values: properties.keys) if property.nil?

          value = property.reader.call(object)
          value = property.default_value(definitions, context: context) if value.nil?
          raise "#{discriminator.property_name} can't be nil" if value.nil?

          schema = definitions.find_schema(discriminator.mapping(value) || value)
          raise "inheriting schema couldn't be found: #{value.inspect}" if schema.nil?

          schema.resolve(definitions).resolve_schema(object, definitions, context: context)
        end

        def to_json_schema # :nodoc:
          super.merge(
            allOf: all_of_references.map(&:to_json_schema).presence,
            properties: properties.transform_values(&:to_json_schema),
            additionalProperties: additional_properties&.to_json_schema,
            required: properties.values.select(&:required?).map(&:name)
          ).compact
        end

        def to_openapi(version) # :nodoc:
          super.merge(
            allOf: all_of_references.map do |schema|
              schema.to_openapi(version)
            end.presence,
            discriminator: discriminator&.to_openapi(version),
            properties: properties.transform_values do |property|
              property.to_openapi(version)
            end,
            additionalProperties: additional_properties&.to_openapi(version),
            required: properties.values.select(&:required?).map(&:name)
          ).compact
        end

        protected

        def merge_properties(definitions, path)
          return properties unless all_of_references.present?

          {}.tap do |properties|
            all_of_references.each do |reference|
              schema = reference.resolve(definitions)
              raise "circular reference: #{reference.ref}" if schema.in?(path)

              properties.merge!(schema.merge_properties(definitions, path + [self]))
            end
            properties.merge!(self.properties)
          end
        end
      end
    end
  end
end
