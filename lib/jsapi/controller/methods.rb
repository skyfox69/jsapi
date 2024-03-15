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
      # are passed as an instance of the operation's model to the block. The object
      # returned by the block is serialized by a +Response+ instance.
      #
      # Example:
      #
      #   api_operation(:foo) do |api_params|
      #     bar(api_params)
      #   end
      #
      def api_operation(operation_name = nil, status: nil, &block)
        params = api_params(operation_name)
        status_codes = api_status_codes(status)

        if status_codes.invalid && params.invalid?
          status_code = status_codes.invalid
          render(
            json: api_response(
              BadRequestError.new(params.errors, status: status_code),
              operation_name,
              status: status_code
            ),
            status: status_code
          )
          return
        end

        status_code = status_codes.default
        if block
          render(
            json: api_response(
              block.call(params),
              operation_name,
              status: status_code
            ),
            status: status_code
          )
        else
          head(status_code)
        end
      end

      # Returns the request parameters as an instance of the operations's model.
      #
      # Example:
      #
      #   api_params(:foo)
      #
      def api_params(operation_name = nil)
        operation = api_definitions.operation(operation_name)
        raise "operation not defined: '#{operation_name}'" if operation.nil?

        (operation.model || Model::Base).new(
          Parameters.new(params, operation, api_definitions)
        )
      end

      # Returns a +Response+ instance to serialize +object+ according to the
      # response definition of the given API operation and status.
      #
      # Example:
      #
      #   render(json: api_response(bar, :foo, status: 200))
      #
      def api_response(object, operation_name = nil, status: nil)
        operation = api_definitions.operation(operation_name)
        raise "operation not defined: '#{operation_name}'" if operation.nil?

        response = operation.response(status)
        raise "status code not defined: '#{status}'" if response.nil?

        Response.new(object, response, api_definitions)
      end

      def api_status_codes(status_codes)
        case status_codes
        when StatusCodes
          status_codes
        when Hash
          StatusCodes.new(**status_codes)
        else
          StatusCodes.new(default: status_codes)
        end
      end
    end
  end
end
