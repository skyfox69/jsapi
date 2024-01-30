# frozen_string_literal: true

module Jsapi
  module DSL
    class Path < Node
      def operation(method, operation_id, **options, &block)
        wrap_error(method, "'#{operation_id}'") do
          operation_model = model.add_operation(method, operation_id, **options)
          Operation.new(operation_model).call(&block) if block.present?
        end
      end
    end
  end
end
