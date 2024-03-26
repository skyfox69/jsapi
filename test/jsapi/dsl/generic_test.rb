# frozen_string_literal: true

module Jsapi
  module DSL
    class GenericTest < Minitest::Test
      def test_generic_keyword
        node = Meta::OpenAPI::Node.new
        Generic.new(node).call { foo 'bar' }
        assert_equal({ foo: 'bar' }, node.to_h)
      end

      def test_generic_child_node
        node = Meta::OpenAPI::Node.new
        Generic.new(node).call do
          nested foo: 'bar'
        end
        assert_equal({ nested: { foo: 'bar' } }, node.to_h)
      end

      def test_generic_child_node_with_block
        node = Meta::OpenAPI::Node.new
        Generic.new(node).call do
          nested { foo 'bar' }
        end
        assert_equal({ nested: { foo: 'bar' } }, node.to_h)
      end

      def test_respond_to
        generic = Generic.new(Meta::OpenAPI::Node.new)
        assert(generic.respond_to?(:foo))
      end
    end
  end
end
