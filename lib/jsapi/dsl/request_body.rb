# frozen_string_literal: true

module Jsapi
  module DSL
    class RequestBody < Node
      delegate(*Schema::COMMON_METHODS, to: :schema)

      private

      def schema
        @schema ||= Schema.new(model.schema)
      end
    end
  end
end
