# frozen_string_literal: true

module Jsapi
  module Controller
    module Methods
      # Returns the API definitions of the caller's class.
      def api_definitions
        self.class.api_definitions
      end

      # Performs an API operation by calling the given block. The request parameters
      # are passed as an instance of the operation's model class to the block. This
      # method implicitly renders the JSON representation of the object returned by
      # the block according to the +response+ definition of the operation and HTTP
      # status code.
      #
      # +operation_name+ can be +nil+ or omitted if the controller handles one API
      # operation only.
      #
      # Example:
      #
      #   api_operation('foo') do |api_params|
      #     # ...
      #   end
      #
      def api_operation(operation_name = nil, status: :default, &block)
        _perform_api_operation(operation_name, false, status: status, &block)
      end

      # Like +api_operation+, except that a ParametersInvalid exception is raised
      # if the request parameters are invalid.
      #
      # Example:
      #
      #   api_operation!('foo') do |api_params|
      #     # ...
      #   end
      #
      def api_operation!(operation_name = nil, status: :default, &block)
        _perform_api_operation(operation_name, true, status: status, &block)
      end

      # Returns the request parameters as an instance of the operation's model class.
      #
      # +operation_name+ can be +nil+ or omitted if the controller handles one API
      # operation only.
      #
      # Example:
      #
      #   params = api_params('foo')
      #
      def api_params(operation_name = nil)
        definitions = api_definitions
        _api_params(_api_operation(operation_name, definitions), definitions)
      end

      # Returns a Response to serialize the JSON representation of +result+ according
      # to the +response+ definition of the operation and HTTP status code.
      #
      # +operation_name+ can be +nil+ or omitted if the controller handles one API
      # operation only.
      #
      # Example:
      #
      #   render(json: api_response(bar, 'foo', status: 200))
      #
      def api_response(result, operation_name = nil, status: :default)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        Response.new(result, response, api_definitions)
      end

      private

      def _api_operation(operation_name, definitions)
        operation = definitions.operation(operation_name)
        return operation if operation

        raise "operation not defined: #{operation_name}"
      end

      def _api_params(operation, definitions)
        (operation.model || Model::Base).new(
          Parameters.new(params, operation, definitions)
        )
      end

      def _api_response(operation, status, definitions)
        response = operation.response(status)
        return response.resolve(definitions) if response

        raise "status code not defined: #{status}"
      end

      def _perform_api_operation(operation_name, bang, status:, &block)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        if block
          params = _api_params(operation, definitions)
          result = begin
            raise ParametersInvalid.new(params) if bang && params.invalid?

            block.call(params)
          rescue StandardError => e
            # Lookup a rescue handler
            rescue_handler = definitions.rescue_handler_for(e)
            raise e if rescue_handler.nil?

            # Change the HTTP status code and response schema
            status = rescue_handler.status
            response = operation.response(status)&.resolve(definitions)
            raise e if response.nil?

            Error.new(e, status: status)
          end
          render(json: Response.new(result, response, definitions), status: status)
        else
          head(status)
        end
      end
    end
  end
end
