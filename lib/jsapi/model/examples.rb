# frozen_string_literal: true

module Jsapi
  module Model
    module Examples
      def add_example(name_or_value = nil, **options)
        if options.any?
          # add_example('foo', value: 'bar', ...)
          name = name_or_value&.to_s
        else
          # add_example('foo')
          name = nil
          options = { value: name_or_value }
        end

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
