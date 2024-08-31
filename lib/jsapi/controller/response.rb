# frozen_string_literal: true

module Jsapi
  module Controller
    # Used to serialize a response.
    class Response

      # Creates a new instance to serialize +object+ according to +response+. References
      # are resolved to API components in +definitions+.
      def initialize(object, response, definitions)
        @object = object
        @response = response
        @definitions = definitions
      end

      def inspect # :nodoc:
        "#<#{self.class.name} #{@object.inspect}>"
      end

      # Returns the JSON representation of the response as a +String+.
      def to_json(*)
        schema = @response.schema.resolve(@definitions)
        if @response.locale
          I18n.with_locale(@response.locale) do
            serialize(@object, schema)
          end
        else
          serialize(@object, schema)
        end.to_json
      end

      private

      def serialize(object, schema, path = nil)
        return if object.nil? && schema.nullable?
        raise "#{path || 'response'} can't be nil" if object.nil?

        case schema.type
        when 'array'
          serialize_array(object, schema, path)
        when 'integer'
          schema.convert(object.to_i)
        when 'number'
          schema.convert(object.to_f)
        when 'object'
          serialize_object(object, schema, path)
        when 'string'
          schema.convert(
            case schema.format
            when 'date'
              object.to_date
            when 'date-time'
              object.to_datetime
            when 'duration'
              object.iso8601
            else
              object.to_s
            end
          )
        else
          object
        end
      end

      def serialize_array(array, schema, path)
        item_schema = schema.items.resolve(@definitions)
        Array(array).map { |item| serialize(item, item_schema, path) }
      end

      def serialize_object(object, schema, path)
        return if object.blank? # {}

        # Select inherriting schema on polymorphism
        if (discriminator = schema.discriminator)
          discriminator_property = schema.properties[discriminator.property_name]
          schema = discriminator.resolve(
            object.public_send(discriminator_property.source || discriminator_property.name.underscore),
            @definitions
          )
        end
        # Serialize properties
        properties = schema.resolve_properties(:read, @definitions).transform_values do |property|
          serialize(
            if (method_chain = property.source).present?
              method_chain.call(object)
            else
              object.public_send(property.name.underscore)
            end,
            property.schema.resolve(@definitions),
            path.nil? ? property.name : "#{path}.#{property.name}"
          )
        end
        if (additional_properties = schema.additional_properties&.resolve(@definitions))
          additional_properties_schema = additional_properties.schema.resolve(@definitions)

          additional_properties.source&.call(object)&.each do |key, value|
            # Don't replace the property with the same key
            next if properties.key?(key = key.to_s)

            # Serialize the additional property
            properties[key] = serialize(
              value,
              additional_properties_schema,
              path.nil? ? key : "#{path}.#{key}"
            )
          end
        end
        properties
      end
    end
  end
end
