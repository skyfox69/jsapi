# frozen_string_literal: true

module Jsapi
  module DSL
    module NestedSchema
      extend ActiveSupport::Concern

      included do
        delegate(
          :all_of,
          :default,
          :enum,
          :format,
          :items,
          :max_items,
          :max_length,
          :maximum,
          :min_items,
          :min_length,
          :minimum,
          :pattern,
          :property,
          to: :schema
        )
      end

      private

      def schema
        @schema ||= Schema.new(_meta_model.schema)
      end
    end
  end
end
