# frozen_string_literal: true

module Jsapi
  module Controller
    # Used to wrap request parameters.
    class Parameters
      include Model::Nestable

      def initialize(params, operation, definitions)
        @attributes = {}

        # Merge parameters and request body properties
        meta_models = operation.parameters.transform_values do |parameter|
          parameter.resolve(definitions)
        end
        if (schema = operation.request_body&.schema).respond_to?(:properties)
          meta_models.merge!(schema.properties(definitions))
        end

        # Wrap params
        meta_models.each do |name, meta_model|
          @attributes[name] = DOM.wrap(params[name], meta_model.schema, definitions)
        end
      end

      # Validates the request parameters. Returns true if the parameters are
      # valid, false otherwise. Validation errors are added to +errors+.
      def validate(errors)
        validate_attributes(errors)
      end
    end
  end
end
