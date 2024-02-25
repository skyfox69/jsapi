# frozen_string_literal: true

module Jsapi
  module DSL
    class GenericTest < Minitest::Test
      def test_generic_keyword
        generic_model = Model::Generic.new
        Generic.new(generic_model).call { foo 'bar' }
        assert_equal({ foo: 'bar' }, generic_model.to_h)
      end

      def test_generic_child_node
        generic_model = Model::Generic.new
        Generic.new(generic_model).call { nested foo: 'bar' }
        assert_equal({ nested: { foo: 'bar' } }, generic_model.to_h)
      end

      def test_respond_to
        generic = Generic.new(Model::Generic.new)
        assert(generic.respond_to?(:foo))
      end
    end
  end
end
