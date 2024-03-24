# frozen_string_literal: true

module Jsapi
  module DSL
    module Example

      # Specifies an example.
      #
      #   example 'foo'
      #
      # The default name is <code>'default'</code>.
      #
      # Raises an Error if an example with the specified name has already
      # been defined.
      #
      # ==== Options
      #
      # [+:value+]
      #   The sample value.
      #     example 'foo', value: 'bar'
      # [+:external+]
      #   If +true+, +:value+ is interpreted as a URI pointing to an external
      #   sample value.
      #     example 'foo', value: 'https//foo.bar/example', external: true
      # [+:summary+]
      #   A short summary of the example.
      # [+:description+]
      #   A description of the example.
      #
      def example(name_or_value = nil, **options, &block)
        node('example', name_or_value) do
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
end
