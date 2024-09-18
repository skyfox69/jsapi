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
          assert_equal('bar', klass.new(foo: 'bar').foo)

          error = assert_raises(ArgumentError) { klass.new(bar: 'bar') }
          assert_equal('unsupported keyword: bar', error.message)
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
