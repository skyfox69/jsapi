# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define a response.
    class Response < Schema
      include OpenAPI::Examples

      ##
      # :method: deprecated
      # :args: arg
      # Specifies whether or not the response is deprecated.
      #
      #   deprecated true

      ##
      # :method: description
      # :args: arg
      # Specifies the description of the response.

      # Defines a link or refers a reusable link object.
      #
      #   # define a link
      #   link 'foo', operation_id: 'bar'
      #
      #   # refer a reusable link
      #   link ref: 'foo'
      #
      # Refers the reusable link object with the same name if neither any
      # keywords nor a block is specified.
      #
      #   link 'foo'
      #
      def link(name = nil, **keywords, &block)
        _define('link', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          link_model = _meta_model.add_link(name, keywords)
          Base.new(link_model, &block) if block
        end
      end

      ##
      # :method: locale
      # :args: arg
      # Specifies the locale to be used when rendering a response.
      #
      #   locale :en
    end
  end
end
