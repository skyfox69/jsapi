# frozen_string_literal: true

module Jsapi
  module DSL
    class Response < Node
      delegate(*Schema::COMMON_METHODS, to: :schema)
      delegate(:nullable, to: :schema)

      private

      def schema
        @schema ||= Schema.new(model.schema)
      end
    end
  end
end
