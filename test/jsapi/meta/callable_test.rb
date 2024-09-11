# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class CallableTest < Minitest::Test
      def test_from_proc
        proc = ->(object) { object }
        assert_equal(proc, Callable.from(proc))
      end

      def test_from_symbol
        callable = Callable.from(:foo)
        assert_kind_of(Callable::SymbolEvaluator, callable)
        assert_equal(:foo, callable.symbol)
      end

      def test_from_symbol_sequence
        callable = Callable.from(%i[foo bar])
        assert_kind_of(Callable::SymbolSequenceEvaluator, callable)
        assert_equal(%i[foo bar], callable.symbols)
      end

      def test_from_string
        callable = Callable.from('foo')
        assert_kind_of(Callable::SymbolEvaluator, callable)
        assert_equal(:foo, callable.symbol)

        callable = Callable.from('foo.bar')
        assert_kind_of(Callable::SymbolSequenceEvaluator, callable)
        assert_equal(%i[foo bar], callable.symbols)
      end

      def test_raises_an_exception_on_blank_argument
        error = assert_raises(ArgumentError) { Callable.from(nil) }
        assert_equal("argument can't be blank", error.message)
      end
    end
  end
end
