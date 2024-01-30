# frozen_string_literal: true

module Jsapi
  module Model
    module Parameter
      class Base
        attr_accessor :description, :example, :location, :name
        attr_reader :schema
        attr_writer :deprecated, :required

        def initialize(name, **options)
          raise ArgumentError, "Parameter name can't be blank" if name.blank?

          @name = name.to_s
          @location = options[:in]
          @description = options[:description]
          @required = options[:required]
          @deprecated = options[:deprecated]
          @example = options[:example]
          @schema = Schema.new(**options.except(:deprecated, :description, :example, :in, :required))
        end

        def deprecated?
          @deprecated == true
        end

        def required?
          @required == true || location == 'path'
        end

        def resolve(_definitions)
          self
        end

        # Returns the OpenAPI parameter objects as an array of hashes.
        def to_openapi_parameters
          if location == 'query' && schema.type == 'object'
            schema.properties.map do |_key, property|
              {
                name: "#{name}[#{property.name}]",
                in: 'query',
                description: property.schema.description,
                required: property.required?,
                deprecated: property.deprecated?,
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
                deprecated: deprecated?,
                schema: schema.to_openapi_schema,
                example: example
              }.compact
            ]
          end
        end
      end
    end
  end
end
