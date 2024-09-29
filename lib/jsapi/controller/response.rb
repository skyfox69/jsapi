# frozen_string_literal: true

module Jsapi
  module Controller
    # Used to serialize a response.
    class Response
      class JsonifyError < RuntimeError # :nodoc:
        def message
          [@path&.delete_prefix('.') || 'response body', super].join(' ')
        end

        def prepend(origin)
          @path = "#{origin}#{@path}"
          self
        end
      end

      # Creates a new instance to serialize +object+ according to +response+. References
      # are resolved to API components in +definitions+.
      #
      # The +:omit+ option specifies on which conditions properties are omitted.
      # Possible values are:
      #
      # - +:empty+ - All of the  properties whose value is empty are omitted.
      # - +:nil+ - All of the properties whose value is +nil+ are omitted.
      #
      # Raises an ArgumentError when the value of +:omit+ is invalid.
      def initialize(object, response, definitions, omit: nil)
        unless omit.in?([:empty, :nil, nil])
          raise InvalidArgumentError.new('omit', omit, valid_values: %i[empty nil])
        end

        @object = object
        @response = response
        @definitions = definitions
        @omit = omit
      end

      def as_json
        schema = @response.schema.resolve(@definitions)
        jsonify(@object, schema)
      end

      def inspect # :nodoc:
        "#<#{self.class.name} #{@object.inspect}>"
      end

      # Returns the JSON representation of the response as a string.
      def to_json(*)
        if @response.locale
          I18n.with_locale(@response.locale) { as_json }
        else
          as_json
        end.to_json
      end

      private

      def jsonify(object, schema)
        object = schema.default_value(@definitions, context: :response) if object.nil?

        if object.nil?
          raise JsonifyError, "can't be nil" unless schema.nullable?
        else
          case schema.type
          when 'array'
            jsonify_array(object, schema)
          when 'integer'
            schema.convert(object.to_i)
          when 'number'
            schema.convert(object.to_f)
          when 'object'
            jsonify_object(object, schema)
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
      end

      def jsonify_array(array, schema)
        item_schema = schema.items.resolve(@definitions)
        Array(array).map { |item| jsonify(item, item_schema) }
      end

      def jsonify_object(object, schema)
        schema = schema.resolve_schema(object, @definitions, context: :response)

        {}.tap do |properties|
          # Properties
          schema.resolve_properties(@definitions, context: :response).each do |key, property|
            property_schema = property.schema.resolve(@definitions)
            property_value = property.reader.call(object)
            property_value = property_schema.default if property_value.nil?

            next if ((@omit == :empty && property_value.try(:empty?)) ||
                    (@omit == :nil && property_value.nil?)) &&
                    property_schema.omittable?

            properties[key] = jsonify(property_value, property_schema)
          rescue JsonifyError => e
            raise e.prepend(".#{property.name}")
          end
          # Additional properties
          if (additional_properties = schema.additional_properties)
            additional_properties_schema = additional_properties.schema.resolve(@definitions)

            additional_properties.source.call(object)&.each do |key, value|
              next if properties.key?(key = key.to_s)

              properties[key] = jsonify(value, additional_properties_schema)
            rescue JsonifyError => e
              raise e.prepend(".#{key}")
            end
          end
        end.presence
      end
    end
  end
end
