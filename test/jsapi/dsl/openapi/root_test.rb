# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      class RootTest < Minitest::Test
        def test_callback
          openapi_root = Meta::OpenAPI::Root.new
          Root.new(openapi_root) { callback 'onFoo' }
          assert_predicate(openapi_root.callback('onFoo'), :present?)
        end
      end
    end
  end
end
