# frozen_string_literal: true

module Jsapi
  module Controller
    class Parameters
      include Validation

      def initialize(params, operation, definitions)
        params = params.permit(*operation.parameters.keys)

        @parameters = operation.parameters.transform_values do |model|
          model = model.resolve(definitions)
          DOM.wrap(params[model.name], model.schema)
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
