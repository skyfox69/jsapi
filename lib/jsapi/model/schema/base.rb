# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Base
        def self.json_schema_validation(*keywords)
          keywords.each do |keyword|
            attr_reader keyword

            # attr writer
            define_method("#{keyword}=") do |value|
              variable_name = "@#{keyword}"

              if instance_variable_defined?(variable_name)
                raise "#{keyword} already defined"
              end

              add_validator(keyword, value)
              instance_variable_set(variable_name, value)
            end
          end
        end

        attr_accessor :default, :description, :example
        attr_reader :existence, :type, :validators

        json_schema_validation :enum

        def initialize(**options)
          @existence = Existence.from(options[:existence])
          @type = options[:type]
          @validators = []

          options.except(:type, :existence).each do |key, value|
            method = "#{key}="
            raise ArgumentError, "invalid option: '#{key}'" unless respond_to?(method)

            send(method, value)
          end
        end

        %w[array boolean integer number object string].each do |type|
          define_method "#{type}?" do
            self.type == type
          end
        end

        def add_validator(key, value)
          class_name = "Jsapi::Model::Schema::Validators::#{key.to_s.camelize(:upper)}"
          @validators << class_name.constantize.new(value)
        end

        def existence=(existence)
          @existence = Existence.from(existence)
        end

        # Returns +true+ if and only if values can be +null+ as
        # specified by JSON Schema.
        def nullable?
          existence <= Existence::ALLOW_NIL
        end

        # Returns itself.
        def resolve(_definitions)
          self
        end

        def to_json_schema(definitions = nil)
          {
            type: nullable? ? [type, 'null'] : type,
            definitions: definitions&.schemas&.transform_values(&:to_json_schema)
          }.merge(json_schema_options).compact
        end

        def to_openapi_schema(version)
          {
            type: type,
            nullable: (true if version == '3.0.3' && nullable?),
            description: description,
            default: default,
            example: example
          }.merge(json_schema_options).compact
        end

        private

        def json_schema_options
          enum.present? ? { enum: enum } : {}
        end
      end
    end
  end
end
