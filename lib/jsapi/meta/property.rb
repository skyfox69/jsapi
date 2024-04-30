# frozen_string_literal: true

module Jsapi
  module Meta
    class Property < Base
      ##
      # :attr_reader: name
      # The name of the property.
      attribute :name, writer: false

      ##
      # :attr_reader: schema
      # The Schema of the parameter.
      attribute :schema, writer: false

      ##
      # :attr: source
      # The alternative method to read a property value when serializing
      # an object.
      attribute :source, Symbol

      delegate_missing_to :schema

      # Creates a new property.
      #
      # Raises an +ArgumentError+ if +name+ is blank.
      def initialize(name, keywords = {})
        raise ArgumentError, "property name can't be blank" if name.blank?

        keywords = keywords.dup
        super(keywords.extract!(:source))

        @name = name.to_s
        @schema = Schema.new(keywords)
      end

      # Returns true if the property is required, false otherwise.
      def required?
        schema.existence > Existence::ALLOW_OMITTED
      end
    end
  end
end
