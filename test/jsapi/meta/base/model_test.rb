# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Base
      class ModelTest < Minitest::Test
        def test_initialize
          klass = Class.new(Model) do
            attribute :foo
          end
          model = klass.new(foo: 'bar')
          assert_equal('bar', model.foo)

          error = assert_raises(ArgumentError) do
            klass.new(foo_bar: 'bar')
          end
          assert_equal('unsupported keyword: foo_bar', error.message)
        end

        def test_merge
          klass = Class.new(Model) do
            attribute :foo
            attribute :bar
          end
          model = klass.new(foo: 'foo', bar: 'foo')
          result = model.merge!(foo: 'bar')

          assert(model.equal?(result))
          assert_equal('bar', model.foo)
          assert_equal('foo', model.bar)

          error = assert_raises(ArgumentError) do
            model.merge!(foo_bar: 'bar')
          end
          assert_equal('unsupported keyword: foo_bar', error.message)
        end

        def test_reference_predicate
          assert(!Model.new.reference?)
        end

        def test_resolve
          model = Model.new
          assert(model.equal?(model.resolve))
        end

        def test_inspect
          klass = Class.new(Model) do
            attribute :foo
            attribute :bar
          end
          assert_equal('#< foo: "Foo", bar: nil>', klass.new(foo: 'Foo').inspect)
          assert_equal('#< foo: "Foo">', klass.new(foo: 'Foo').inspect(:foo))
        end
      end
    end
  end
end
