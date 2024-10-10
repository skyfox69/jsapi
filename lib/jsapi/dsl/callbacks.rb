# frozen_string_literal: true

module Jsapi
  module DSL
    module Callbacks
      # Specifies an OpenAPI callback object or refers a reusable callback object.
      #
      #   # specify a callback object
      #   callback 'foo' do
      #     operation '{$request.query.foo}'
      #   end
      #
      #   # refer a reusable callback object
      #   callback ref: 'foo'
      #
      # Refers the reusable callback object with the same name if neither any
      # keywords nor a block is specified.
      #
      #   callback 'foo'
      #
      def callback(name = nil, **keywords, &block)
        _define('callback', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          callback_model = _meta_model.add_callback(name, keywords)
          _eval(callback_model, Callback, &block)
        end
      end
    end
  end
end
