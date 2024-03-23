# frozen_string_literal: true

module Jsapi
  module Meta
    module Examples
      def add_example(name = nil, **options)
        name = name.presence || 'default'
        raise "Example already defined: #{name}" if examples.key?(name)

        examples[name] = Example.new(**options)
      end

      def examples
        @examples ||= {}
      end

      def openapi_examples
        examples.transform_values(&:to_openapi_example)
      end
    end
  end
end
