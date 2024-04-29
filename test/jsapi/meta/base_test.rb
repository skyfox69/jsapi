# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class BaseTest < Minitest::Test
      def test_initialize
        dummy_class = Class.new(Base) do
          attribute :foo
        end
        dummy = dummy_class.new(foo: 'bar')
        assert_equal('bar', dummy.foo)

        error = assert_raises(ArgumentError) do
          dummy_class.new(bar: 'bar')
        end
        assert_equal('unsupported keyword: bar', error.message)
      end

      def test_inspect
        dummy_class = Class.new(Base) do
          attribute :foo
          attribute :bar
        end
        assert_equal(
          '#< foo: "Foo", bar: nil>',
          dummy_class.new(foo: 'Foo').inspect
        )
      end
    end
  end
end

