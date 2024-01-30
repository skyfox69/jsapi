# frozen_string_literal: true

module Jsapi
  module DSL
    class Property < Node
      delegate(*Schema::COMMON_METHODS, to: :schema)
      delegate(:description, :example, to: :schema)

      private

      def schema
        @schema ||= Schema.new(model.schema)
      end
    end
  end
end
