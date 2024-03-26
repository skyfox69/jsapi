# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Base
        attr_accessor :default, :description
        attr_reader :examples, :existence, :type, :validations

        def initialize(**options)
          @examples = options.key?(:example) ? [options[:example]] : []
          @existence = Existence.from(options[:existence])
          @type = options[:type]
          @validations = {}

          options.except(:example, :existence, :type).each do |key, value|
            method = "#{key}="
            raise ArgumentError, "invalid option: #{key}" unless respond_to?(method)

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

        def enum=(value)
          add_validation('enum', Validation::Enum.new(value))
        end

        def existence=(existence)
          @existence = Existence.from(existence)
        end

        # Returns true if and only if values can be +null+ as specified
        # by JSON Schema.
        def nullable?
          existence <= Existence::ALLOW_NIL
        end

        # Returns itself.
        def resolve(_definitions)
          self
        end

        def to_json_schema
          {
            type: nullable? ? [type, 'null'] : type,
            description: description,
            default: default,
            examples: examples.presence
          }.tap do |hash|
            validations.each_value do |validation|
              hash.merge!(validation.to_json_schema_validation)
            end
          end.compact
        end

        def to_openapi_schema(version)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            {
              type: type,
              description: description,
              default: default,
              example: examples.first
            }
          elsif version.minor == 0
            {
              type: type,
              nullable: nullable?.presence,
              description: description,
              default: default,
              examples: examples.presence
            }
          else # 3.1
            {
              type: nullable? ? [type, 'null'] : type,
              description: description,
              default: default,
              examples: examples.presence
            }
          end.tap do |hash|
            validations.each_value do |validation|
              hash.merge!(validation.to_openapi_validation(version))
            end
          end.compact
        end

        private

        def add_validation(keyword, validation)
          validations[keyword] = validation
        end
      end
    end
  end
end
