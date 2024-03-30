# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      DummyModel = Struct.new(:foo)

      def test_generic_field
        dummy = DummyModel.new
        Node.new(dummy).call { foo 'bar' }
        assert_equal('bar', dummy.foo)
      end

      def test_raises_error_on_invalid_keyword
        node = Node.new(DummyModel.new)
        error = assert_raises do
          node.call { bar 'foo' }
        end
        assert_equal("invalid keyword: 'bar'", error.message)
      end

      def test_raises_error_on_invalid_nested_keyword
        error = assert_raises Error do
          Schema.new(Meta::Schema.new).call do
            property('foo') { bar 'bar' }
          end
        end
        assert_equal("invalid keyword: 'bar' (at 'foo')", error.message)
      end

      def test_respond_to
        node = Node.new(DummyModel.new)
        assert(node.respond_to?(:foo))
      end

      def test_respond_to_on_invalid_keyword
        node = Node.new(DummyModel.new)
        assert(!node.respond_to?(:bar))
      end
    end
  end
end
