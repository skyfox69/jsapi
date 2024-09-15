# frozen_string_literal: true

module Jsapi
  module Controller
    # Used to wrap request parameters.
    class Parameters
      include Model::Nestable

      attr_reader :raw_additional_attributes, :raw_attributes

      # Creates a new instance that wraps +params+ according to +operation+. References are
      # resolved to API components in +definitions+.
      #
      # If +strong+ is true+ parameters that can be mapped are accepted only. That means that
      # the instance created is invalid if +params+ contains any parameters that can't be
      # mapped to a parameter or a request body property of +operation+.
      def initialize(params, headers, operation, definitions, strong: false)
        @params = params.to_h
        @strong = strong == true
        @raw_attributes = {}
        @raw_additional_attributes = {}

        # Parameters
        operation.parameters.each do |name, parameter_model|
          parameter_model = parameter_model.resolve(definitions)

          @raw_attributes[name] = JSON.wrap(
            parameter_model.in == 'header' ? headers[name] : @params[name],
            parameter_model.schema.resolve(definitions),
            definitions
          )
        end

        # Request body
        request_body_schema = operation.request_body&.resolve(definitions)
                                       &.schema&.resolve(definitions)
        if request_body_schema&.object?
          request_body = JSON.wrap(
            @params.except(*operation.parameters.keys),
            request_body_schema,
            definitions
          )
          @raw_attributes.merge!(request_body.raw_attributes)
          @raw_additional_attributes = request_body.raw_additional_attributes
        end
      end

      # Validates the request parameters. Returns true if the parameters are valid, false
      # otherwise. Detected errors are added to +errors+.
      def validate(errors)
        [
          validate_attributes(errors),
          !@strong || validate_parameters(@params, attributes, errors)
        ].all?
      end

      private

      def validate_parameters(params, attributes, errors, path = [])
        params.each.map do |key, value|
          if attributes.key?(key)
            # Validate nested parameters
            !value.respond_to?(:keys) || validate_parameters(
              value,
              attributes[key].try(:attributes) || {},
              errors,
              path + [key]
            )
          else
            errors.add(
              :base,
              I18n.translate(
                'jsapi.errors.forbidden',
                default: "'%<name>s' isn't allowed",
                name: path.empty? ? key : (path + [key]).join('.')
              )
            )
            false
          end
        end.all?
      end
    end
  end
end
