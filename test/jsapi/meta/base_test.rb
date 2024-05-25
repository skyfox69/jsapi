# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class BaseTest < Minitest::Test
      def test_initialize
        klass = Class.new(Base) do
          attribute :foo
        end
        assert_equal('bar', klass.new(foo: 'bar').foo)

        error = assert_raises(ArgumentError) { klass.new(bar: 'bar') }
        assert_equal('unsupported keyword: bar', error.message)
      end

      def test_inspect
        klass = Class.new(Base) do
          attribute :foo
          attribute :bar
        end
        assert_equal(
          '#< foo: "Foo", bar: nil>',
          klass.new(foo: 'Foo').inspect
        )
      end

      def test_reference_predicate
        assert(!Base.new.reference?)
      end

      def test_resolve
        meta_model = Base.new
        assert(meta_model.equal?(meta_model.resolve))
      end
    end
  end
end
