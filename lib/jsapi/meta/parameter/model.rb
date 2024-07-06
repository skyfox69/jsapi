# frozen_string_literal: true

module Jsapi
  module Meta
    module Parameter
      class Model < Base
        include OpenAPI::Extensions

        ##
        # :attr: deprecated
        # Specifies whether or not the parameter is deprecated.
        attribute :deprecated, values: [true, false]

        ##
        # :attr: description
        # The description of the parameter.
        attribute :description, String

        ##
        # :attr_reader: examples
        # The examples.
        attribute :examples, { String => Example }, default_key: 'default'

        ##
        # :attr: in
        # The location of the parameter. Possible values are:
        #
        # - <code>"path"</code>
        # - <code>"query"</code>
        #
        # The default location is <code>"query"</code>.
        attribute :in, String, values: %w[path query], default: 'query'

        ##
        # :attr_reader: name
        # The name of the parameter.
        attribute :name, writer: false

        ##
        # :attr_reader: schema
        # The Schema of the parameter.
        attribute :schema, writer: false

        delegate_missing_to :schema

        # Creates a new parameter.
        #
        # Raises an +ArgumentError+ if +name+ is blank.
        def initialize(name, keywords = {})
          raise ArgumentError, "parameter name can't be blank" if name.blank?

          @name = name.to_s

          keywords = keywords.dup
          super(keywords.extract!(:deprecated, :description, :examples, :in))

          add_example(value: keywords.delete(:example)) if keywords.key?(:example)
          keywords[:ref] = keywords.delete(:schema) if keywords.key?(:schema)

          @schema = Schema.new(keywords)
        end

        # Returns true if empty values are allowed as specified by \OpenAPI,
        # false otherwise.
        def allow_empty_value?
          schema.existence <= Existence::ALLOW_EMPTY && self.in != 'path'
        end

        # Returns true if it is required as specified by \JSON \Schema,
        # false otherwise.
        def required?
          schema.existence > Existence::ALLOW_OMITTED || self.in == 'path'
        end

        # Returns an array of hashes representing the \OpenAPI parameter objects.
        def to_openapi(version, definitions)
          version = OpenAPI::Version.from(version)
          schema = self.schema.resolve(definitions)

          if schema.object?
            explode_object_parameter(
              name,
              schema,
              version,
              definitions,
              required: required?,
              deprecated: deprecated?
            )
          else
            parameter_name = schema.array? ? "#{name}[]" : name
            [
              with_openapi_extensions(
                if version.major == 2
                  {
                    name: parameter_name,
                    in: self.in,
                    description: description,
                    required: required?.presence,
                    allowEmptyValue: allow_empty_value?.presence,
                    collectionFormat: ('multi' if schema.array?)
                  }.merge(schema.to_openapi(version))
                else
                  {
                    name: parameter_name,
                    in: self.in,
                    description: description,
                    required: required?.presence,
                    allowEmptyValue: allow_empty_value?.presence,
                    deprecated: deprecated?.presence,
                    schema: schema.to_openapi(version),
                    examples: examples&.transform_values(&:to_openapi)

                    # NOTE: collectionFormat is replaced by style and explode.
                    #       The default values for query parameters are:
                    #       - style: 'form'
                    #       - explode: true
                  }
                end
              )
            ]
          end
        end

        private

        def explode_object_parameter(name, schema, version, definitions, **options)
          schema.resolve_properties(:read, definitions).values.flat_map do |property|
            property_schema = property.schema.resolve(definitions)
            parameter_name = "#{name}[#{property.name}]"

            required = (property.required? && options[:required]).presence
            deprecated = (property.deprecated? || options[:deprecated]).presence

            if property_schema.object?
              explode_object_parameter(
                parameter_name,
                property_schema,
                version,
                definitions,
                required: required,
                deprecated: deprecated
              )
            else
              parameter_name = "#{parameter_name}[]" if property_schema.array?
              description = property_schema.description
              allow_empty_value = property.schema.existence <= Existence::ALLOW_EMPTY
              [
                with_openapi_extensions(
                  if version.major == 2
                    {
                      name: parameter_name,
                      in: self.in,
                      description: description,
                      required: required,
                      allowEmptyValue: allow_empty_value.presence,
                      collectionFormat: ('multi' if property_schema.array?)
                    }.merge(property_schema.to_openapi(version))
                  else
                    {
                      name: parameter_name,
                      in: self.in,
                      description: description,
                      required: required,
                      allowEmptyValue: allow_empty_value.presence,
                      deprecated: deprecated,
                      schema: property_schema.to_openapi(version).except(:deprecated),
                      examples: examples&.transform_values(&:to_openapi)
                    }
                  end
                )
              ]
            end
          end
        end
      end
    end
  end
end
