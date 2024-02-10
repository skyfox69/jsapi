# frozen_string_literal: true

module Jsapi
  module DOM
    class BaseObject
      include Validation

      attr_reader :schema

      def initialize(schema)
        @schema = schema
      end

      def null?
        false
      end

      def empty?
        false
      end

      def _validate
        case schema.existence
        when Model::Existence::PRESENT
          errors.add(:blank) if empty?
        when Model::Existence::ALLOW_EMPTY
          errors.add(:blank) if null?
        end
        return if invalid?

        schema.validate(self)
      end
    end
  end
end
