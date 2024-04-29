# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Base < Meta::Base
        TYPES = %w[array boolean integer number object string].freeze # :nodoc:

        TYPES.each do |type|
          define_method("#{type}?") { self.type == type }
        end

        ##
        # :attr: default
        # The optional default value.
        attribute :default

        ##
        # :attr: description
        # The optional description of the schema.
        attribute :description, ::String

        ##
        # :attr: enum
        # The allowed values.
        attribute :enum, writer: false

        ##
        # :attr: examples
        # The optional examples.
        attribute :examples, [::Object]

        ##
        # :attr: external_docs
        # The optional OpenAPI::ExternalDocumentation object.
        attribute :external_docs, OpenAPI::ExternalDocumentation

        ##
        # :attr: existence
        # The level of Existence. The default level of existence
        # is +ALLOW_OMITTED+.
        attribute :existence, Existence, default: Existence::ALLOW_OMITTED

        ##
        # :attr_reader: type
        # The type of the schema as a string.

        # The validations.
        attr_reader :validations

        # Creates a new schema.
        def initialize(keywords = {})
          keywords = keywords.dup
          add_example(keywords.delete(:example)) if keywords.key?(:example)

          @type = keywords.delete(:type)
          @validations = {}
          super(keywords)
        end

        def enum=(value) # :nodoc:
          add_validation('enum', Validation::Enum.new(value))
          @enum = value
        end

        # Returns true if and only if values can be +null+ as specified
        # by \JSON \Schema.
        def nullable?
          existence <= Existence::ALLOW_NIL
        end

        # Returns itself.
        def resolve(*)
          self
        end

        # Returns a hash representing the \JSON \Schema object.
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

        # Returns a hash representing the \OpenAPI schema object.
        def to_openapi_schema(version)
          version = OpenAPI::Version.from(version)
          if version.major == 2
            # OpenAPI 2.0
            {
              type: type,
              example: examples&.first
            }
          elsif version.minor.zero?
            # OpenAPI 3.0
            {
              type: type,
              nullable: nullable?.presence,
              examples: examples
            }
          else
            # OpenAPI 3.1
            {
              type: nullable? ? [type, 'null'] : type,
              examples: examples
            }
          end.tap do |hash|
            hash[:description] = description
            hash[:default] = default
            hash[:externalDocs] = external_docs&.to_openapi

            validations.each_value do |validation|
              hash.merge!(validation.to_openapi_validation(version))
            end
          end.compact
        end

        def type # :nodoc:
          @type ||= self.class.name.demodulize.downcase
        end

        private

        def add_validation(keyword, validation)
          validations[keyword] = validation
        end
      end
    end
  end
end
