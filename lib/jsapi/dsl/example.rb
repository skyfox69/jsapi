# frozen_string_literal: true

module Jsapi
  module DSL
    module Example

      # Specifies an example.
      #
      #   example 'foo', value: { bar: 'foo' }
      #
      # ==== Options
      #
      # [+:value+]
      #   The sample value.
      # [+:external_value+]
      #   The URI of an external sample value.
      # [+:summary+]
      #   A short summary of the example.
      # [+:description+]
      #   A description of the example.
      #
      def example(name_or_value = nil, **options, &block)
        if options.any? || block
          # example 'foo', value: 'bar', ...
          name = name_or_value
        else
          # example 'foo'
          name = nil
          options = { value: name_or_value }
        end
        example = _meta_model.add_example(name, **options)
        Node.new(example).call(&block) if block
      end
    end
  end
end
