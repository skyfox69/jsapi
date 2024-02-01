# frozen_string_literal: true

module Jsapi
  module Controller
    module Methods
      private

      # Returns the API definitions of the current class.
      def api_definitions
        self.class.api_definitions
      end

      # Performs an API operation by calling the given block. The parameters are
      # passed as a +Parameters+ instance to the block. The object returned by the
      # block is serialized by a +Response+ object.
      #
      # Example:
      #
      #   api_operation :my_operation do |api_params|
      #     Article.find_by(api_params.id)
      #   end
      def api_operation(operation_name = nil, status: nil, &block)
        head(status) && return if block.nil?

        response = api_response(block.call(api_params(operation_name)), operation_name, status: status)
        render(json: response, status: status)
      end

      # Returns a +Parameters+ object that wraps the parameters returned by +params+.
      def api_params(operation_name = nil)
        operation = api_definitions.operation(operation_name)
        raise "operation not defined: '#{operation_name}'" if operation.nil?

        Parameters.new(params, operation, api_definitions)
      end

      # Returns a +Response+ object that wraps +object+.
      def api_response(object, operation_name = nil, status: nil)
        operation = api_definitions.operation(operation_name)
        raise "operation not defined: '#{operation_name}'" if operation.nil?

        response = operation.response(status)
        raise "status code not defined: '#{status}'" if response.nil?

        Response.new(object, response.schema, api_definitions)
      end
    end
  end
end
