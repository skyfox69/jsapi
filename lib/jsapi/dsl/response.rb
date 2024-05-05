# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a response.
    class Response < Schema
      include Example

      # Defines a link. This method can be used to define a link object in
      # place or to refer a reusable link object.
      #
      #   link 'foo', operation_id: 'bar'
      #
      #   link ref: 'foo'
      #
      # Refers to the reusable link object with the same name if neither any
      # keywords nor a block is specified.
      def link(name = nil, **keywords, &block)
        define('link', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          link_model = _meta_model.add_link(name, keywords)
          Node.new(link_model).call(&block) if block
        end
      end
    end
  end
end
