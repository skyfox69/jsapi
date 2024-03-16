# frozen_string_literal: true

module Jsapi
  module Controller
    module Methods
      private

      # Returns the API definitions of the current class.
      def api_definitions
        self.class.api_definitions
      end

      # Performs an API operation by calling the given block. The request parameters
      # are passed as an instance of the operation's model class to the block. The
      # object returned by the block is serialized by a +Response+.
      #
      # Raises an +ArgumentError+ if the operation or status is not defined.
      #
      # Example:
      #
      #   api_operation(:foo) do |api_params|
      #     bar(api_params)
      #   end
      #
      def api_operation(operation_name = nil, status: nil, &block)
        _perform_api_operation(operation_name, bang: false, status: status, &block)
      end

      # Analogous to +api_operation+. Raises an +InvalidParametersError+ if parameters
      # are invalid.
      #
      def api_operation!(operation_name = nil, status: nil, &block)
        _perform_api_operation(operation_name, bang: true, status: status, &block)
      end

      # Returns the request parameters as an instance of the operations's model class.
      def api_params(operation_name = nil)
        _api_params(_api_operation(operation_name, api_definitions))
      end

      # Returns a +Response+ instance to serialize +object+ according to the response
      # definition of the given API operation and status.
      #
      # Example:
      #
      #   render(json: api_response(bar, :foo, status: 200))
      #
      def api_response(object, operation_name = nil, status: nil)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        Response.new(object, response, api_definitions)
      end

      # Internal methods

      def _api_operation(operation_name, definitions)
        operation = definitions.operation(operation_name)
        return operation if operation.present?

        raise ArgumentError, "operation not defined: '#{operation_name}'"
      end

      def _api_params(operation)
        (operation.model || Model::Base).new(
          Parameters.new(params, operation, api_definitions)
        )
      end

      def _api_response(operation, status, definitions)
        response = operation.response(status)
        return response.resolve(definitions) if response.present?

        raise ArgumentError, "status code not defined: '#{status}'"
      end

      def _perform_api_operation(operation_name, bang:, status:, &block)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        if block
          payload = begin
            params = _api_params(operation)
            raise ParametersInvalid.new(params) if bang && params.invalid?

            block.call(params)
          rescue StandardError => e
            rescue_handler = definitions.rescue_handler_for(e)
            raise e if rescue_handler.nil?

            status = rescue_handler.status
            response = _api_response(operation, status, definitions)
            NestedError.new(e, status: status)
          end
          render(json: Response.new(payload, response, definitions), status: status)
        else
          head(status)
        end
      end
    end
  end
end
