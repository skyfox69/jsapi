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

        method_chain = MethodChain.new('foo')
        assert_equal('bar', method_chain.call(object))

        method_chain = MethodChain.new('bar')
        assert_nil(method_chain.call(object, safe_send: true))
        assert_raises(NoMethodError) { method_chain.call(object) }
      end

      def test_call_on_multiple_methods
        nested = Struct.new(:bar).new('foo')
        object = Struct.new(:foo).new(nested)

        method_chain = MethodChain.new('foo.bar')
        assert_equal('foo', method_chain.call(object))

        method_chain = MethodChain.new('foo.foo')
        assert_nil(method_chain.call(object, safe_send: true))
        assert_raises(NoMethodError) { method_chain.call(object) }
      end
    end
  end
end
