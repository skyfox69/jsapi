# frozen_string_literal: true

module Jsapi
  module DSL
    module ClassMethods
      # The API definitions of the current class.
      def api_definitions(&block)
        @api_definitions ||= Meta::Definitions.new(self)
        Definitions.new(@api_definitions).call(&block) if block.present?
        @api_definitions
      end

      # See +Definitions#include+
      def api_include(*classes)
        api_definitions { include(*classes) }
      end

      # See +Definitions#operation+
      def api_operation(name = nil, &block)
        api_definitions { operation(name, &block) }
      end

      # See +Definitions#parameter+
      def api_parameter(name, **options, &block)
        api_definitions { parameter(name, **options, &block) }
      end

      # See +Definitions#rescue_from+
      def api_rescue_from(*klasses, with: nil)
        api_definitions { rescue_from(*klasses, with: with) }
      end

      # See +Definitions#response+
      def api_response(name, **options, &block)
        api_definitions { response(name, **options, &block) }
      end

      # See +Definitions#schema+
      def api_schema(name, **options, &block)
        api_definitions { schema(name, **options, &block) }
      end

      # See +Definitions#openapi+
      def openapi(version = '2.0', &block)
        api_definitions { openapi(version, &block) }
      end
    end
  end
end
