# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Base
        attr_accessor :default, :description, :example
        attr_reader :enum, :existence, :type, :validators

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

        def add_validator(key, value)
          class_name = "Jsapi::Model::Validators::#{key.to_s.camelize(:upper)}"
          @validators << class_name.constantize.new(value)
        end

        def enum=(enum)
          raise 'enum already defined' if instance_variable_defined?(:@enum)

          add_validator(:enum, enum)
          @enum = enum
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

        def to_json_schema(definitions = nil, include: [])
          {
            type: nullable? ? [type, 'null'] : type,
            definitions: definitions&.schemas&.slice(*include)
                                    &.transform_values(&:to_json_schema)
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
          { enum: enum }
        end

        def set_json_schema_validation(key, value)
          var = "@#{key}"
          raise "#{key} already defined" if instance_variable_defined?(var)

          add_validator(key, value)
          instance_variable_set(var, value)
        end
      end
    end
  end
end
