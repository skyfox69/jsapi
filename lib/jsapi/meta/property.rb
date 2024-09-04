# frozen_string_literal: true

module Jsapi
  module Meta
    class Property < Base::Model
      delegate_missing_to :schema

      ##
      # :attr_reader: name
      # The name of the property.
      attribute :name, writer: false

      ##
      # :attr: read_only
      attribute :read_only, values: [true, false]

      ##
      # :attr_reader: schema
      # The Schema of the parameter.
      attribute :schema, writer: false

      ##
      # :attr: source
      # The alternative MethodChain to be called when reading a property value.
      attribute :source, MethodChain

      ##
      # :attr: write_only
      attribute :write_only, values: [true, false]

      # Creates a new property.
      #
      # Raises an +ArgumentError+ if +name+ is blank.
      def initialize(name, keywords = {})
        raise ArgumentError, "property name can't be blank" if name.blank?

        @name = name.to_s

        keywords = keywords.dup
        super(keywords.extract!(:read_only, :source, :write_only))
        keywords[:ref] = keywords.delete(:schema) if keywords.key?(:schema)

        @schema = Schema.new(keywords)
      end

      # Returns the MethodChain to be called when reading a property value.
      def method_chain
        source || (@method_chain ||= MethodChain.new(name.underscore))
      end

      # Returns true if the level of existence is greater than or equal to +ALLOW_NIL+,
      # false otherwise.
      def required?
        schema.existence >= Existence::ALLOW_NIL
      end

      # Returns a hash representing the \OpenAPI schema object.
      def to_openapi(version)
        version = OpenAPI::Version.from(version)

        schema.to_openapi(version).tap do |hash|
          hash[:readOnly] = true if read_only?
          hash[:writeOnly] = true if write_only? && version.major > 2
        end
      end
    end
  end
end
