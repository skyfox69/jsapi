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
          @validators = {}

          options.except(:type, :existence).each do |key, value|
            method = "#{key}="
            raise ArgumentError, "invalid option: '#{key}'" unless respond_to?(method)

            send(method, value)
          end
        end

        def add_validator(validator)
          (@validators[:custom] ||= []) << validator if validator.present?
        end

        def enum=(value)
          register_validator(:enum, @enum = value)
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
            definitions: definitions&.schemas&.slice(*include)&.transform_values(&:to_json_schema)
          }.merge(json_schema_options).compact
        end

        def to_openapi_schema
          {
            type: type,
            nullable: (true if nullable?), # only 3.0.x
            description: description,
            default: default,
            example: example
          }.merge(json_schema_options).compact
        end

        def validate(object)
          errors = object.errors
          value = object.cast

          @validators.each_value do |validators|
            Array(validators).each do |validator|
              validator.validate(value, errors)
            end
          end
        end

        private

        def json_schema_options
          { enum: enum }
        end

        def register_validator(key, value)
          if value.nil?
            @validators.delete(key)
          else
            class_name = "Jsapi::Validators::#{key.to_s.camelize(:upper)}"
            @validators[key] = class_name.constantize.new(value)
          end
        end
      end
    end
  end
end
