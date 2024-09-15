# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      module Callbacks
        # Defines an \OpenAPI callback or refers a reusable callback.
        #
        #   # define a callback
        #   callback 'foo' do
        #     operation '{$request.query.foo}'
        #   end
        #
        #   # refer a reusable callback
        #   callback ref: 'foo'
        #
        # Refers the reusable callback with the same name if neither any
        # keywords nor a block is specified.
        #
        #   callback 'foo'
        #
        def callback(name = nil, **keywords, &block)
          _define('callback', name&.inspect) do
            name = keywords[:ref] if name.nil?
            keywords = { ref: name } unless keywords.any? || block

            callback_model = _meta_model.add_callback(name, keywords)
            _eval(callback_model, OpenAPI::Callback, &block)
          end
        end
      end
    end
  end
end
