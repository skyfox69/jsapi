# frozen_string_literal: true

module Jsapi
  module DSL
    module ClassMethods
      # The API definitions of the current class.
      def api_definitions(&block)
        @api_definitions ||= Meta::Definitions.new(self)
        Definitions.new(@api_definitions).call(&block) if block
        @api_definitions
      end

      # Includes API definitions from +klasses+.
      def api_include(*klasses)
        api_definitions { include(*klasses) }
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
      def api_operation(name = nil, **options, &block)
        api_definitions { operation(name, **options, &block) }
      end

      # Defines a reusable parameter.
      #
      #   api_parameter 'foo', type: 'string'
      #
      def api_parameter(name, **options, &block)
        api_definitions { parameter(name, **options, &block) }
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
      def api_response(name, **options, &block)
        api_definitions { response(name, **options, &block) }
      end

      # Defines a reusable schema.
      #
      #   api_schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      def api_schema(name, **options, &block)
        api_definitions { schema(name, **options, &block) }
      end

      # Defines the root of an OpenAPI document.
      #
      #   openapi do
      #     info title: 'Foo', version: '1'
      #   end
      def openapi(**keywords, &block)
        api_definitions { openapi(keywords, &block) }
      end
    end
  end
end
