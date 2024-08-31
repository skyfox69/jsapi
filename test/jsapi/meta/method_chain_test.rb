# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class MethodChainTest < Minitest::Test
      def test_initialize
        # Single methods
        assert_equal(%i[foo], MethodChain.new(:foo).methods)
        assert_equal(%i[foo], MethodChain.new('foo').methods)

        # Chained methods
        assert_equal(%i[foo bar], MethodChain.new('foo.bar').methods)
        assert_equal(%i[foo bar], MethodChain.new(%w[foo bar]).methods)
      end

      def test_inspect
        assert_equal(
          '#<Jsapi::Meta::MethodChain [:foo, :bar]>',
          MethodChain.new('foo.bar').inspect
        )
      end

      def test_call_on_empty_method_chain
        assert_nil(MethodChain.new(nil).call(nil))
      end

      def test_call_on_single_method
        object = Struct.new(:foo).new('bar')
        assert_equal('bar', MethodChain.new('foo').call(object))
      end

      def test_call_on_multiple_methods
        nested = Struct.new(:bar).new('foo')
        object = Struct.new(:foo).new(nested)
        assert_equal('foo', MethodChain.new('foo.bar').call(object))
      end
    end
  end
end
