# frozen_string_literal: true

module Jsapi
  module DSL
    module ClassMethods
      # Specifies the general default values for +type+.
      #
      #   api_default 'array', read: [], write: []
      #
      def api_default(type, **keywords, &block)
        api_definitions { default(type, **keywords, &block) }
      end

      # The API definitions of the current class.
      def api_definitions(&block)
        @api_definitions ||= Meta::Definitions.new(
          owner: self,
          parent: superclass.try(:api_definitions)
        )
        Definitions.new(@api_definitions, &block) if block
        @api_definitions
      end

      # Includes API definitions from +klasses+.
      def api_include(*klasses)
        api_definitions { include(*klasses) }
      end

      # Registers a callback to be called when rescuing an exception.
      def api_on_rescue(method = nil, &block)
        api_definitions { on_rescue(method, &block) }
      end

      # Defines an operation.
      #
      #   api_operation 'foo', path: '/foo' do
      #     parameter 'bar', type: 'string'
      #     response do
      #       property 'foo', type: 'string'
      #     end
      #   end
      #
      # +name+ can be +nil+ if the controller handles one operation only.
      def api_operation(name = nil, **keywords, &block)
        api_definitions { operation(name, **keywords, &block) }
      end

      # Defines a reusable parameter.
      #
      #   api_parameter 'foo', type: 'string'
      #
      def api_parameter(name, **keywords, &block)
        api_definitions { parameter(name, **keywords, &block) }
      end

      # Defines a reusable request body.
      #
      #   api_request_body 'foo', type: 'string'
      #
      def api_request_body(name, **keywords, &block)
        api_definitions { request_body(name, **keywords, &block) }
      end

      # Specifies the HTTP status code of an error response rendered when an
      # exception of any of +klasses+ has been raised.
      #
      #   api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400
      #
      def api_rescue_from(*klasses, with: nil)
        api_definitions { rescue_from(*klasses, with: with) }
      end

      # Defines a reusable response.
      #
      #   api_response 'Foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      def api_response(name, **keywords, &block)
        api_definitions { response(name, **keywords, &block) }
      end

      # Defines a reusable schema.
      #
      #   api_schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      def api_schema(name, **keywords, &block)
        api_definitions { schema(name, **keywords, &block) }
      end

      # Defines the root of an OpenAPI document.
      #
      #   openapi do
      #     info title: 'Foo', version: '1'
      #   end
      def openapi(**keywords, &block)
        api_definitions { openapi(**keywords, &block) }
      end
    end
  end
end
