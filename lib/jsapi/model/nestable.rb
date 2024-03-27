# frozen_string_literal: true

module Jsapi
  module Model
    module Nestable

      # Returns the value assigned to +name+.
      def [](name)
        raw_attributes[name&.to_s]&.value
      end

      # Returns +true+ if +name+ is present, false +otherwise+.
      def attribute?(name)
        raw_attributes.key?(name&.to_s)
      end

      # Returns a +Hash+ containing all attributes.
      def attributes
        raw_attributes.transform_values(&:value)
      end

      private

      def validate_attributes(errors)
        raw_attributes.map do |key, value|
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
