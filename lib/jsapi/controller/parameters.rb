# frozen_string_literal: true

module Jsapi
  module Controller
    class Parameters
      include Validation

      def initialize(params, operation, definitions)
        # Merge parameters and request body properties
        models = operation.parameters.transform_values do |parameter|
          parameter.resolve(definitions)
        end
        if (schema = operation.request_body&.schema).respond_to?(:properties)
          models.merge!(schema.properties)
        end

        # Wrap params
        @parameters = models.each_with_object({}) do |(name, model), p|
          p[name] = DOM.wrap(params[name], model.schema, definitions)
        end
      end

      def[](key)
        @parameters[key&.to_s]&.cast
      end

      def _validate
        @parameters.each do |key, parameter|
          next if parameter.valid?

          parameter.errors.each do |error|
            errors << AttributeError.new(key, error)
          end
        end
      end

      def method_missing(*args)
        name = args.first.to_s
        @parameters.key?(name) ? self[name] : super
      end

      def respond_to_missing?(param1, _param2)
        @parameters.key?(param1.to_s) ? true : super
      end
    end
  end
end
