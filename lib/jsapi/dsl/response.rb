# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define a response.
    class Response < Schema
      include Examples

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

      # Specifies an HTTP header of the response.
      #
      #   header 'X-Foo', type: 'string'
      #
      # Refers a resuable header if the `:ref` keyword is specified.
      #
      #   header ref: 'x_foo'
      #
      # Refers the reusable header with the same name if neither any keywords
      # nor a block is specified.
      #
      #   header 'x_foo'
      #
      # See Meta::Response::Model#headers for further information.
      def header(name = nil, **keywords, &block)
        define('header', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          header_model = @meta_model.add_header(name, keywords)
          Base.new(header_model, &block) if block
        end
      end

      # Specifies a link.
      #
      #   link 'foo', operation_id: 'bar'
      #
      # Refers a reusable link if the `:ref` keyword is specified.
      #
      #   link ref: 'foo'
      #
      # Refers the reusable link with the same name if neither any keywords
      # nor a block is specified.
      #
      #   link 'foo'
      #
      def link(name = nil, **keywords, &block)
        define('link', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          link_model = @meta_model.add_link(name, keywords)
          Base.new(link_model, &block) if block
        end
      end

      ##
      # :method: locale
      # :args: arg
      # Specifies the locale to be used when producing a response.
      #
      #   locale :en
    end
  end
end
