# frozen_string_literal: true

module Jsapi
  module DSL
    module ClassMethods
      # The API definitions of the current class.
      # TODO: Describe block
      def api_definitions(&block)
        @api_definitions ||= Model::Definitions.new
        Definitions.new(@api_definitions).call(&block) if block.present?
        @api_definitions
      end

      # See +Definitions#parameter+
      def api_parameter(name, **options, &block)
        api_definitions { parameter(name, **options, &block) }
      end

      # See +Definitions#path+
      def api_path(path, &block)
        api_definitions { path(path, &block) }
      end

      # See +Definitions#schema+
      def api_schema(name, **options, &block)
        api_definitions { schema(name, **options, &block) }
      end
    end
  end
end
