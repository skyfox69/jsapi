# frozen_string_literal: true

module Jsapi
  module Model
    class Parameter
      attr_accessor :description, :example, :name
      attr_reader :location, :schema
      attr_writer :deprecated

      def initialize(name, **options)
        raise ArgumentError, "parameter name can't be blank" if name.blank?

        @name = name.to_s
        @location = options[:in]
        @description = options[:description]
        @deprecated = options[:deprecated] == true
        @example = options[:example]
        @schema = Schema.new(**options.except(:deprecated, :description, :example, :in))
      end

      def deprecated?
        @deprecated == true
      end

      # Returns +true+ if and only if the parameter is required as specified
      # by JSON Schema.
      def required?
        schema.existence > Existence::ALLOW_OMITTED || location == 'path'
      end

      def resolve(_definitions)
        self
      end

      # Returns the OpenAPI parameter objects as an array of hashes.
      def to_openapi_parameters(version)
        type = schema.respond_to?(:type) ? schema.type : nil

        if version == '2.0'
          if type == 'object'
            schema.properties.values.map do |property|
              {
                name: "#{name}[#{property.name}]",
                in: location,
                description: property.schema.description,
                required: required? && property.required?
              }.merge(property.schema.to_openapi_schema(version)).compact
            end
          else
            [
              {
                name: name,
                in: location,
                description: description,
                required: required?
              }.merge(schema.to_openapi_schema(version)).compact
            ]
          end
        else
          [
            {
              name: name,
              in: location,
              description: description,
              required: required?,
              deprecated: (true if deprecated?),
              schema: schema.to_openapi_schema(version),
              explode: (true if %w[array object].include?(type)),
              example: example
            }.compact
          ]
        end
      end
    end
  end
end
