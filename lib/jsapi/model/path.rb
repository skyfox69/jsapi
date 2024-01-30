# frozen_string_literal: true

module Jsapi
  module Model
    class Path
      attr_reader :operations

      def initialize
        @operations = {}
      end

      def add_operation(method, operation_id, **options)
        raise ArgumentError, "Method can't be blank" if method.blank?

        operations[method.to_s] = Operation.new(operation_id, **options)
      end

      # Returns the OpenAPI path object as a +Hash+.
      def to_openapi_path
        operations.transform_values(&:to_openapi_operation)
      end
    end
  end
end
