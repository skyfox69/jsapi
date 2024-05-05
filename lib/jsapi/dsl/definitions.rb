# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define top-level API components.
    class Definitions < Node
      def call(&block) # :nodoc:
        define { super }
      end

      # Includes API definitions from +klasses+.
      def include(*klasses)
        klasses.each do |klass|
          _meta_model.include(klass.api_definitions)
        end
      end

      # Defines an operation.
      #
      #   operation 'foo', path: '/foo' do
      #     parameter 'bar', type: 'string'
      #     response do
      #       property 'foo', type: 'string'
      #     end
      #   end
      #
      # +name+ can be +nil+ if the controller handles one operation only.
      def operation(name = nil, **keywords, &block)
        define('operation', name&.inspect) do
          operation_model = _meta_model.add_operation(name, keywords)
          Operation.new(operation_model).call(&block) if block
        end
      end

      # Defines a reusable parameter.
      #
      #   parameter 'foo', type: 'string'
      #
      def parameter(name, **keywords, &block)
        define('parameter', name.inspect) do
          parameter_model = _meta_model.add_parameter(name, keywords)
          Parameter.new(parameter_model).call(&block) if block
        end
      end

      # Specifies the HTTP status code of an error response rendered when an
      # exception of any of +klasses+ has been raised.
      #
      #   rescue_from Jsapi::Controller::ParametersInvalid, with: 400
      #
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler(klass, status: with)
        end
      end

      # Defines a reusable response.
      #
      #   response 'Foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      def response(name, **keywords, &block)
        define('response', name.inspect) do
          response_model = _meta_model.add_response(name, keywords)
          Response.new(response_model).call(&block) if block
        end
      end

      # Defines a reusable schema.
      #
      #   schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      def schema(name, **keywords, &block)
        define('schema', name.inspect) do
          schema_model = _meta_model.add_schema(name, keywords)
          Schema.new(schema_model).call(&block) if block
        end
      end
    end
  end
end
