# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class RootTest < Minitest::Test
        def test_to_h
          root = Root.new
          root.add_child(:info, title: 'Foo')

          assert_equal(
            { swagger: '2.0', info: { title: 'Foo' } },
            root.to_h('2.0')
          )
          assert_equal(
            { openapi: '3.0.3', info: { title: 'Foo' } },
            root.to_h('3.0')
          )
          assert_equal(
            { openapi: '3.1.0', info: { title: 'Foo' } },
            root.to_h('3.1')
          )
        end
      end
    end
  end
end
