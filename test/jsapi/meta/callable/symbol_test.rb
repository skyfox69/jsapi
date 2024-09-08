# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Callable
      class SymbolTest < Minitest::Test
        def test_inspect
          assert_equal(
            '#<Jsapi::Meta::Callable::Symbol :foo>',
            Symbol.new(:foo).inspect
          )
        end

        def test_call
          symbol = Symbol.new(:foo)

          assert_nil(symbol.call(nil))

          object = Struct.new(:foo).new('bar')
          assert_equal('bar', symbol.call(object))

          hash = { foo: 'bar' }
          assert_equal('bar', symbol.call(hash))
        end
      end
    end
  end
end
