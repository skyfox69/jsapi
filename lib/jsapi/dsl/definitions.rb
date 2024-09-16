# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define top-level API components.
    class Definitions < Node

      # Specifies the general default values for +type+.
      #
      #   default 'array', read: [], write: []
      #
      def default(type, **keywords, &block)
        _define('default', type.inspect) do
          default = _meta_model.add_default(type, keywords)
          Node.new(default, &block) if block
        end
      end

      # Includes API definitions from +klasses+.
      def include(*klasses)
        klasses.each do |klass|
          _meta_model.include(klass.api_definitions)
        end
      end

      # Registers a callback to be called when rescuing an exception.
      def on_rescue(method = nil, &block)
        _define('on_rescue') do
          _meta_model.add_on_rescue(method || block)
        end
      end

      # Defines the root of an \OpenAPI document.
      #
      #   openapi do
      #     info title: 'Foo', version: '1'
      #   end
      def openapi(**keywords, &block)
        _define('openapi') do
          _meta_model.openapi_root = keywords
          OpenAPI::Root.new(_meta_model.openapi_root, &block) if block
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
        _define('operation', name&.inspect) do
          operation_model = _meta_model.add_operation(name, keywords)
          Operation.new(operation_model, &block) if block
        end
      end

      # Defines a reusable parameter.
      #
      #   parameter 'foo', type: 'string'
      #
      def parameter(name, **keywords, &block)
        _define('parameter', name.inspect) do
          parameter_model = _meta_model.add_parameter(name, keywords)
          Parameter.new(parameter_model, &block) if block
        end
      end

      # Defines a reusable request body.
      #
      #   request_body 'foo', type: 'string'
      #
      def request_body(name, **keywords, &block)
        _define('request_body', name.inspect) do
          request_body_model = _meta_model.add_request_body(name, keywords)
          RequestBody.new(request_body_model, &block) if block
        end
      end

      # Specifies the HTTP status code of an error response rendered when an exception of
      # any of +klasses+ has been raised.
      #
      #   rescue_from Jsapi::Controller::ParametersInvalid, with: 400
      #
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler({ error_class: klass, status: with })
        end
      end

      # Defines a reusable response.
      #
      #   response 'Foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      def response(name, **keywords, &block)
        _define('response', name.inspect) do
          response_model = _meta_model.add_response(name, keywords)
          Response.new(response_model, &block) if block
        end
      end

      # Defines a reusable schema.
      #
      #   schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      def schema(name, **keywords, &block)
        _define('schema', name.inspect) do
          schema_model = _meta_model.add_schema(name, keywords)
          Schema.new(schema_model, &block) if block
        end
      end
    end
  end
end
