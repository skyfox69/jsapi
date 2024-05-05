# frozen_string_literal: true

module Jsapi
  module Meta
    module OpenAPI
      module Callback
        # Represents a callback object. Applies to \OpenAPI 3.x.
        class Base < Meta::Base
          ##
          # :attr: operations
          # The operations.
          attribute :operations, writer: false, default: {}

          # Adds an operation.
          def add_operation(expression, operation_name, keywords = {})
            raise ArgumentError, "expression can't be blank" if expression.blank?

            (@operations ||= {})[expression.to_s] = Operation.new(operation_name, keywords)
          end

          # Returns a hash representing the callback object.
          def to_openapi(version, definitions)
            operations.transform_values do |operation|
              { operation.method => operation.to_openapi_operation(version, definitions) }
            end
          end
        end
      end
    end
  end
end
