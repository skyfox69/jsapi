# frozen_string_literal: true

module Jsapi
  module Model
    class Example
      attr_accessor :description, :external_value, :summary, :value

      def initialize(**options)
        @summary = options[:summary]
        @description = options[:description]
        @value = options[:value]
        @external_value = options[:external_value]
      end

      def to_openapi_example
        {
          summary: summary,
          description: description,
          value: value,
          external_value: external_value
        }.compact
      end
    end
  end
end
