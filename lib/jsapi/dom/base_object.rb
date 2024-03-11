# frozen_string_literal: true

module Jsapi
  module DOM
    class BaseObject
      attr_reader :schema

      def initialize(schema)
        @schema = schema
        @errors = nil
      end

      def empty?
        false
      end

      def null?
        false
      end

      def validate(errors)
        if (schema.existence >= Meta::Existence::ALLOW_EMPTY && null?) ||
           (schema.existence == Meta::Existence::PRESENT && empty?)
          errors.add(:base, :blank)
          return false
        end
        return true if null?

        schema.validations.each_value.map do |validation|
          validation.validate(value, errors)
        end.all?
      end
    end
  end
end
