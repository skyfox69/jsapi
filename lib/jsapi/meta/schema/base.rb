# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      class Base < Meta::Base::Model
        include OpenAPI::Extensions

        ##
        # :attr: default
        # The default value.
        attribute :default

        ##
        # :attr: deprecated
        # Specifies whether or not the schema is deprecated.
        attribute :deprecated, values: [true, false]

        ##
        # :attr: description
        # The description of the schema.
        attribute :description, ::String

        ##
        # :attr: enum
        # The allowed values.
        attribute :enum, writer: false

        ##
        # :attr: examples
        # The samples matching the schema.
        attribute :examples, [::Object]

        ##
        # :attr: external_docs
        # The OpenAPI::ExternalDocumentation object.
        attribute :external_docs, OpenAPI::ExternalDocumentation

        ##
        # :attr: existence
        # The level of Existence. The default level of existence is +ALLOW_OMITTED+.
        attribute :existence, Existence, default: Existence::ALLOW_OMITTED

        ##
        # :attr: title
        # The title of the schema.
        attribute :title, String

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

        # Returns true if and only if values can be +null+ as specified by \JSON \Schema.
        def nullable?
          existence <= Existence::ALLOW_NIL
        end

        # Returns a hash representing the \JSON \Schema object.
        def to_json_schema
          {
            type: nullable? ? [type, 'null'] : type,
            title: title,
            description: description,
            default: default,
            examples: examples.presence,
            deprecated: deprecated?.presence
          }.tap do |hash|
            validations.each_value do |validation|
              hash.merge!(validation.to_json_schema_validation)
            end
          end.compact
        end

        # Returns a hash representing the \OpenAPI schema object.
        def to_openapi(version)
          version = OpenAPI::Version.from(version)

          with_openapi_extensions(
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
                examples: examples,
                deprecated: deprecated?.presence
              }
            else
              # OpenAPI 3.1
              {
                type: nullable? ? [type, 'null'] : type,
                examples: examples,
                deprecated: deprecated?.presence
              }
            end.tap do |hash|
              hash[:title] = title
              hash[:description] = description
              hash[:default] = default
              hash[:externalDocs] = external_docs&.to_openapi

              validations.each_value do |validation|
                hash.merge!(validation.to_openapi_validation(version))
              end
            end
          )
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
