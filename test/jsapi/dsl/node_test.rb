# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      DummyModel = Struct.new(:foo)

      def test_generic_field
        model = DummyModel.new
        Node.new(model).call { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_raises_error_on_unknown_field
        node = Node.new(DummyModel.new)
        error = assert_raises Error do
          node.call { bar 'foo' }
        end
        assert_equal("unknown or invalid field: 'bar'", error.message)
      end

      def test_respond_to
        node = Node.new(DummyModel.new)
        assert(node.respond_to?(:foo))
      end

      def test_respond_to_on_unknown_field
        node = Node.new(DummyModel.new)
        assert(!node.respond_to?(:bar))
      end

      def test_wrapped_error
        error = assert_raises Error do
          Schema.new(Meta::Schema.new).call do
            property('foo') { bar 'bar' }
          end
        end
        assert_equal("unknown or invalid field: 'bar' (at 'foo')", error.message)
      end
    end
  end
end
