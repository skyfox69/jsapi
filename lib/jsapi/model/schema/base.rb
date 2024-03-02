# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Base
        class << self
          private

          def json_schema_validation(*keywords)
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
        end

        attr_accessor :default, :description
        attr_reader :examples, :existence, :type, :validators

        json_schema_validation :enum

        def initialize(**options)
          @examples = options.key?(:example) ? [options[:example]] : []
          @existence = Existence.from(options[:existence])
          @type = options[:type]
          @validators = []

          options.except(:example, :existence, :type).each do |key, value|
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

        def add_example(example)
          @examples << example
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
            definitions: definitions&.schemas&.transform_values(&:to_json_schema),
            examples: examples.presence
          }.merge(json_schema_options).compact
        end

        def to_openapi_schema(version)
          case version
          when '2.0'
            {
              type: type,
              example: examples.first
            }
          when '3.0'
            {
              type: type,
              nullable: nullable?.presence,
              examples: examples.presence
            }
          when '3.1'
            {
              type: nullable? ? [type, 'null'] : type,
              examples: examples.presence
            }
          else
            raise ArgumentError, "unsupported OpenAPI version: #{version}"
          end.merge(json_schema_options).compact
        end

        private

        def json_schema_options
          {
            default: default,
            description: description,
            enum: enum.presence
          }
        end
      end
    end
  end
end
