# frozen_string_literal: true

module Jsapi
  module DSL
    class GenericTest < Minitest::Test
      def test_generic_keyword
        generic = Meta::Generic.new
        Generic.new(generic).call { foo 'bar' }
        assert_equal({ foo: 'bar' }, generic.to_h)
      end

      def test_generic_child_node
        generic = Meta::Generic.new
        Generic.new(generic).call do
          nested foo: 'bar'
        end
        assert_equal({ nested: { foo: 'bar' } }, generic.to_h)
      end

      def test_generic_child_node_with_block
        generic = Meta::Generic.new
        Generic.new(generic).call do
          nested { foo 'bar' }
        end
        assert_equal({ nested: { foo: 'bar' } }, generic.to_h)
      end

      def test_respond_to
        generic = Generic.new(Meta::Generic.new)
        assert(generic.respond_to?(:foo))
      end
    end
  end
end
