# frozen_string_literal: true

module Jsapi
  module DSL
    module Example
      def example(name_or_value = nil, **options, &block)
        example = _meta_model.add_example(name_or_value, **options)
        Node.new(example).call(&block) if block
      end
    end
  end
end
