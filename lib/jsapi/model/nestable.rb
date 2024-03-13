# frozen_string_literal: true

module Jsapi
  module Model
    module Nestable
      def [](name)
        @attributes[name&.to_s]&.value
      end

      def attribute?(name)
        @attributes.key?(name&.to_s)
      end

      def attributes
        @attributes.transform_values(&:value)
      end

      private

      def validate_attributes(errors)
        @attributes.map do |key, value|
          errors.nested(key) do
            next value.validate(errors) unless value.respond_to?(:model)
            next true if (model = value.model).valid?

            errors.merge!(model)
            false
          end
        end.all?
      end
    end
  end
end
