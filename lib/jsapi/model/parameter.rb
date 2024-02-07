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
        @schema = Schema.new(**options.except(:deprecated, :description, :example, :in, :required))

        self.required = options[:required] == true
      end

      def deprecated?
        @deprecated == true
      end

      def required?
        @required == true || location == 'path'
      end

      def required=(required)
        @required = required == true
        @schema.nullable = !required? if @schema.respond_to?(:nullable=)
      end

      def resolve(_definitions)
        self
      end

      # Returns the OpenAPI parameter objects as an array of hashes.
      def to_openapi_parameters
        if schema.respond_to?(:type) && schema.type == 'object'
          schema.properties.map do |_key, property|
            {
              name: "#{name}[#{property.name}]",
              in: location,
              description: property.schema.description,
              required: property.required?,
              deprecated: (true if property.deprecated?),
              schema: property.schema.to_openapi_schema,
              example: property.schema.example
            }.compact
          end
        else
          [
            {
              name: name,
              in: location,
              description: description,
              required: required?,
              deprecated: (true if deprecated?),
              schema: schema.to_openapi_schema,
              example: example
            }.compact
          ]
        end
      end
    end
  end
end
