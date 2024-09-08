# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Callable
      class SymbolSequenceTest < Minitest::Test
        def test_inspect
          assert_equal(
            '#<Jsapi::Meta::Callable::SymbolSequence [:foo, :bar]>',
            SymbolSequence.new(:foo, :bar).inspect
          )
        end

        def test_call
          symbol_sequence = SymbolSequence.new(:foo, :bar)

          assert_nil(symbol_sequence.call(nil))

          nested = Struct.new(:bar).new('foo')
          object = Struct.new(:foo).new(nested)
          assert_equal('foo', symbol_sequence.call(object))

          hash = { foo: { bar: 'foo' } }
          assert_equal('foo', symbol_sequence.call(hash))

          hash = { foo: nested }
          assert_equal('foo', symbol_sequence.call(hash))
        end
      end
    end
  end
end
