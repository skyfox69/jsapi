# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      DummyModel = Struct.new(:foo)

      def test_method_missing
        model = DummyModel.new
        Node.new(model).call { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_method_missing_on_unknown_field
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

      def test_error_message
        error = assert_raises Error do
          Definitions.new(Model::Definitions.new).call do
            operation 'operation' do
              parameter 'parameter', type: 'object' do
                property('property') { bar 'foo' }
              end
            end
          end
        end
        assert_equal(
          "unknown or invalid field: 'bar' (at 'operation'/'parameter'/'property')",
          error.message
        )
      end
    end
  end
end
