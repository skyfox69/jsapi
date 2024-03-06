# frozen_string_literal: true

module Jsapi
  module Model
    module Schema
      class Base
        attr_accessor :default, :description
        attr_reader :examples, :existence, :type, :validations

        def initialize(**options)
          @examples = options.key?(:example) ? [options[:example]] : []
          @existence = Existence.from(options[:existence])
          @type = options[:type]
          @validations = {}
          @lambda_validations = []

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

        def add_lambda_validation(lambda)
          @lambda_validations << Validation::Lambda.new(lambda)
        end

        def enum=(value)
          add_validation('enum', Validation::Enum.new(value))
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
            description: description,
            default: default,
            examples: examples.presence,
            definitions: definitions&.schemas&.transform_values(&:to_json_schema)
          }.tap do |hash|
            validations.each_value do |validation|
              hash.merge!(validation.to_json_schema_validation)
            end
          end.compact
        end

        def to_openapi_schema(version)
          case version
          when '2.0'
            {
              type: type,
              description: description,
              default: default,
              example: examples.first
            }
          when '3.0'
            {
              type: type,
              nullable: nullable?.presence,
              description: description,
              default: default,
              examples: examples.presence
            }
          when '3.1'
            {
              type: nullable? ? [type, 'null'] : type,
              description: description,
              default: default,
              examples: examples.presence
            }
          else
            raise ArgumentError, "unsupported OpenAPI version: #{version}"
          end.tap do |hash|
            validations.each_value do |validation|
              hash.merge!(validation.to_openapi_validation(version))
            end
          end.compact
        end

        def validate(object)
          case existence
          when Existence::PRESENT
            object.errors.add(:blank) if object.empty?
          when Existence::ALLOW_EMPTY
            object.errors.add(:blank) if object.null?
          end
          return if object.null? || object.invalid?

          validations.each_value { |validation| validation.validate(object) }
          @lambda_validations.each { |validation| validation.validate(object) }
        end

        private

        def add_validation(keyword, validation)
          raise "#{keyword} already defined" if validations.key?(keyword)

          validations[keyword] = validation
        end
      end
    end
  end
end
