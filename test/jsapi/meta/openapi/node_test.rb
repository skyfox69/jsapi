# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class NodeTest < Minitest::Test
        def test_keyword
          node = Node.new(foo: 'bar')
          assert_equal({ foo: 'bar' }, node.to_h)

          node = Node.new
          node[:foo] = 'bar'
          assert_equal({ foo: 'bar' }, node.to_h)
        end

        def test_add_child
          node = Node.new
          node.add_child('foo', bar: 'bar')
          assert_equal({ foo: { bar: 'bar' } }, node.to_h)
        end

        def test_camel_case
          node = Node.new(foo_bar: 'bar')
          assert_equal({ fooBar: 'bar' }, node.to_h)
        end
      end
    end
  end
end
