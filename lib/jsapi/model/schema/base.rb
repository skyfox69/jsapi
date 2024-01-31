# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Base
        attr_accessor :default, :description, :example
        attr_reader :all_of, :enum, :type, :validators
        attr_writer :nullable

        def initialize(**options)
          @type = options[:type]
          @nullable = options[:nullable] == true
          @all_of = []
          @validators = {}

          options.except(:type, :nullable).each do |key, value|
            method = "#{key}="
            raise ArgumentError, "invalid option: '#{key}'" unless respond_to?(method)

            send(method, value)
          end
        end

        def add_all_of(schema_name)
          # TODO: Prevent circular references
          @all_of << Reference.new(schema_name) if schema_name.present?
        end

        def add_validator(validator)
          (@validators[:custom] ||= []) << validator if validator.present?
        end

        def enum=(value)
          register_validator(:enum, @enum = value)
        end

        def nullable?
          @nullable == true
        end

        def resolve(_definitions)
          self
        end

        def to_json_schema(definitions = nil, include: [])
          {
            type: nullable? ? [type, 'null'] : type,
            allOf: @all_of.map(&:to_json_schema).presence,
            definitions: definitions&.schemas&.slice(*include)&.transform_values(&:to_json_schema)
          }.merge(json_schema_options).compact
        end

        def to_openapi_schema
          {
            type: type,
            nullable: (true if nullable?), # only 3.0.x
            description: description,
            allOf: @all_of.map(&:to_openapi_schema).presence,
            default: default,
            example: example
          }.merge(json_schema_options).compact
        end

        def validate(object)
          @validators.each_value do |validators|
            Array(validators).each do |validator|
              validator.validate(object.cast, object.errors)
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
