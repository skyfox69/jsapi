# frozen_string_literal: true

module Jsapi
  module Controller
    # Used to wrap request parameters.
    class Parameters
      include Model::Nestable

      attr_reader :raw_attributes

      # Creates a new instance that wraps +params+ according to +operation+. References are
      # resolved to API components in +definitions+.
      #
      # If +strong+ is true+ parameters that can be mapped are accepted only. That means that
      # the instance created is invalid if +params+ contains any parameters that can't be
      # mapped to a parameter or a request body property of +operation+.
      def initialize(params, operation, definitions, strong: false)
        @params = params
        @strong = strong == true
        @raw_attributes = {}

        # Merge parameters and request body properties
        meta_models = operation.parameters.transform_values do |parameter|
          parameter.resolve(definitions)
        end
        request_body = operation.request_body&.resolve(definitions)
        if request_body && request_body.schema.respond_to?(:properties)
          meta_models.merge!(request_body.schema.resolve_properties(definitions, context: :request))
        end

        # Wrap params
        meta_models.each do |name, meta_model|
          @raw_attributes[name.underscore] = JSON.wrap(params[name], meta_model.schema, definitions)
        end
      end

      def inspect # :nodoc:
        "#<#{self.class.name} " \
        "#{attributes.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
      end

      # Validates the request parameters. Returns true if the parameters are valid, false
      # otherwise. Detected errors are added to +errors+.
      def validate(errors)
        [
          validate_attributes(errors),
          !@strong || validate_parameters(
            @params.except(:controller, :action, :format),
            attributes,
            errors
          )
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
