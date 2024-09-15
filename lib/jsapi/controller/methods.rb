# frozen_string_literal: true

module Jsapi
  module Controller
    module Methods
      # Returns the Meta::Definitions instance associated with the controller class. In
      # particular, this method can be used to create an OpenAPI document, for example:
      #
      #   render(json: api_definitions.openapi_document)
      #
      def api_definitions
        self.class.api_definitions
      end

      # Performs an API operation by calling the given block. The request parameters are
      # passed as an instance of the operation's model class to the block. The object
      # returned by the block is implicitly rendered according to the appropriate +response+
      # specification.
      #
      #   api_operation('foo') do |api_params|
      #     # ...
      #   end
      #
      # +operation_name+ can be +nil+ if the controller handles one operation only.
      #
      # If +:strong+ is +true+, parameters that can be mapped are accepted only. That means
      # that the model passed to the block is invalid if there are any request parameters
      # that can't be mapped to a parameter or a request body property of the operation.
      #
      # The +:omit+ option specifies on which conditions properties are omitted.
      # Possible values are:
      #
      # - +:empty+ - All of the  properties whose value is empty are omitted.
      # - +:nil+ - All of the properties whose value is +nil+ are omitted.
      #
      # Raises an InvalidArgumentError when the value of +:omit+ is invalid.
      def api_operation(operation_name = nil, omit: nil, status: nil, strong: false, &block)
        _perform_api_operation(
          operation_name,
          bang: false,
          omit: omit,
          status: status,
          strong: strong,
          &block
        )
      end

      # Like +api_operation+, except that a ParametersInvalid exception is raised on
      # invalid request parameters.
      #
      #   api_operation!('foo') do |api_params|
      #     # ...
      #   end
      #
      def api_operation!(operation_name = nil, omit: nil, status: nil, strong: false, &block)
        _perform_api_operation(
          operation_name,
          bang: true,
          omit: omit,
          status: status,
          strong: strong,
          &block
        )
      end

      # Returns the request parameters as an instance of the operation's model class.
      # Parameter names are converted to snake case.
      #
      #   params = api_params('foo')
      #
      # +operation_name+ can be +nil+ if the controller handles one operation only.
      #
      # If +strong+ is +true+, parameters that can be mapped are accepted only. That means
      # that the model returned is invalid if there are any request parameters that can't be
      # mapped to a parameter or a request body property of the operation.
      #
      # Note that each call of +api_params+ returns a newly created instance.
      def api_params(operation_name = nil, strong: false)
        definitions = api_definitions
        _api_params(
          _api_operation(operation_name, definitions),
          definitions,
          strong: strong
        )
      end

      # Returns a Response to serialize the JSON representation of +result+ according to the
      # appropriate +response+ specification.
      #
      #   render(json: api_response(bar, 'foo', status: 200))
      #
      # +operation_name+ can be +nil+ if the controller handles one operation only.
      #
      # The +:omit+ option specifies on which conditions properties are omitted.
      # Possible values are:
      #
      # - +:empty+ - All of the  properties whose value is empty are omitted.
      # - +:nil+ - All of the properties whose value is +nil+ are omitted.
      #
      # Raises an InvalidArgumentError when the value of +:omit+ is invalid.
      def api_response(result, operation_name = nil, omit: nil, status: nil)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        Response.new(result, response, api_definitions, omit: omit)
      end

      private

      def _api_operation(operation_name, definitions)
        operation = definitions.operation(operation_name)
        return operation if operation

        raise "operation not defined: #{operation_name}"
      end

      def _api_params(operation, definitions, strong:)
        (operation.model || Model::Base).new(
          Parameters.new(
            params.except(:action, :controller, :format).permit!,
            headers,
            operation,
            definitions,
            strong: strong
          )
        )
      end

      def _api_response(operation, status, definitions)
        response = operation.response(status)
        return response.resolve(definitions) if response

        raise "status code not defined: #{status}"
      end

      def _perform_api_operation(operation_name, bang:, omit:, status:, strong:, &block)
        definitions = api_definitions
        operation = _api_operation(operation_name, definitions)
        response = _api_response(operation, status, definitions)

        if block
          params = _api_params(operation, definitions, strong: strong)
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

            # Call on_rescue callbacks
            definitions.on_rescue_callbacks.each do |callback|
              if callback.respond_to?(:call)
                callback.call(e)
              else
                send(callback, e)
              end
            end

            ErrorResult.new(e, status: status)
          end
          render(json: Response.new(result, response, definitions, omit: omit), status: status)
        else
          head(status)
        end
        self.content_type = response.content_type
      end
    end
  end
end
