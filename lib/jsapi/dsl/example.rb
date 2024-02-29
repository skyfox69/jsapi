# frozen_string_literal: true

module Jsapi
  module DSL
    module Example
      def example(name_or_value = nil, **options, &block)
        wrap_error do
          example = model.add_example(name_or_value, **options)
          Node.new(example).call(&block) if block.present?
        end
      end
    end
  end
end
