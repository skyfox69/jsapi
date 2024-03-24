# frozen_string_literal: true

module Jsapi
  module Meta
    class Example
      attr_accessor :description, :external, :summary, :value

      def initialize(**options)
        @summary = options[:summary]
        @description = options[:description]
        @value = options[:value]
        @external = options[:external] == true
      end

      def to_openapi_example
        {}.tap do |hash|
          hash[:summary] = summary if summary.present?
          hash[:description] = description if description.present?

          if external == true
            hash[:external_value] = value
          else
            hash[:value] = value
          end
        end
      end
    end
  end
end
