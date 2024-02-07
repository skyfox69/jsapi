# frozen_string_literal: true

module Jsapi
  module Model
    class Property
      attr_accessor :name, :source
      attr_reader :schema
      attr_writer :deprecated

      delegate :to_json_schema, :to_openapi_schema, to: :schema

      def initialize(name, **options)
        @name = name&.to_s
        @deprecated = options[:deprecated] == true
        @source = options[:source]
        @schema = Schema.new(**options.except(:deprecated, :source, :required))

        self.required = options[:required] == true
      end

      def deprecated?
        @deprecated == true
      end

      def required?
        @required == true
      end

      def required=(required)
        @required = required == true
        @schema.nullable = !@required if @schema.respond_to?(:nullable=)
      end
    end
  end
end
