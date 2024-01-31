# frozen_string_literal: true

module Jsapi
  module DOM
    class BaseObject
      include Validation

      attr_reader :schema

      def initialize(schema)
        @schema = schema
      end

      def _validate
        schema.validate(self)
      end
    end
  end
end