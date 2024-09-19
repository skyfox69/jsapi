# frozen_string_literal: true

module Jsapi
  module Meta
    module Base
      class AttributesTest < Minitest::Test
        def test_attribute_names
          foo_class = Class.new do
            extend Attributes
            attribute :foo
          end
          bar_class = Class.new(foo_class) do
            attribute :bar
          end
          assert_equal(%i[foo], foo_class.attribute_names)
          assert_equal(%i[foo bar], bar_class.attribute_names)
        end

        # Simple attributes

        def test_attribute
          model = Class.new do
            extend Attributes
            attribute :foo, String, values: %w[foo bar]
          end.new

          assert(model.respond_to?(:foo))
          assert(model.respond_to?(:foo=))

          # Attribute writer and reader
          assert_nil(model.foo)

          model.foo = 'bar'
          assert_equal('bar', model.foo)

          # Errors
          assert_raises(InvalidArgumentError) { model.foo = 'foo_bar' }
        end

        def test_attribute_with_default_value
          default_value = 'bar'

          model = Class.new do
            extend Attributes
            attribute :foo, String, default: default_value
          end.new

          assert_equal(default_value, model.foo)
        end

        def test_read_only_attribute
          model = Class.new do
            extend Attributes
            attribute :foo, String, read_only: true
          end.new

          assert(model.respond_to?(:foo))
          assert(!model.respond_to?(:foo=))
        end

        # Boolean attributes

        def test_boolean_attribute
          model = Class.new do
            extend Attributes
            attribute :foo, values: [true, false]
          end.new

          assert(model.respond_to?(:foo))
          assert(model.respond_to?(:foo?))
          assert(model.respond_to?(:foo=))

          # Attribute writer and reader
          assert(!model.foo?)

          model.foo = true
          assert(model)

          model.foo = false
          assert(!model.foo?)
        end

        def test_read_only_boolean_attribute
          model = Class.new do
            extend Attributes
            attribute :foo, values: [true, false], read_only: true
          end.new

          assert(model.respond_to?(:foo))
          assert(model.respond_to?(:foo?))
          assert(!model.respond_to?(:foo=))
        end

        # Array attributes

        def test_array_attribute
          model = Class.new do
            extend Attributes
            attribute :foos, [String], values: %w[foo bar]
          end.new

          assert(model.respond_to?(:foos))
          assert(model.respond_to?(:foos=))
          assert(model.respond_to?(:add_foo))

          # 'add' method  and attribute writer and reader
          assert_nil(model.foos)

          model.foos = %w[foo]
          assert_equal(%w[foo], model.foos)

          assert_equal('bar', model.add_foo('bar'))
          assert_equal(%w[foo bar], model.foos)

          # Errors
          assert_raises(InvalidArgumentError) { model.foos = %w[foo foo_bar] }
          assert_raises(InvalidArgumentError) { model.add_foo 'foo_bar' }
        end

        def test_array_attribute_with_default_value
          default_value = %w[foo bar]

          model = Class.new do
            extend Attributes
            attribute :foos, [String], default: default_value
          end.new

          assert_equal(default_value, model.foos)
        end

        def test_read_only_array_attribute
          model = Class.new do
            extend Attributes
            attribute :foos, [String], read_only: true
          end.new

          assert(model.respond_to?(:foos))
          assert(!model.respond_to?(:foos=))
          assert(!model.respond_to?(:add_foo))
        end

        # Hash attributes

        def test_hash_attribute
          model = Class.new do
            extend Attributes
            attribute :foos, { String => String }, keys: %w[foo bar], values: %w[FOO BAR]
          end.new

          assert(model.respond_to?(:foos))
          assert(model.respond_to?(:add_foo))

          # 'add' method and attribute reader
          assert_nil(model.foos)
          assert_nil(model.foo('foo'))

          model.add_foo('foo', 'BAR')
          assert_equal({ 'foo' => 'BAR' }, model.foos)

          assert_equal('BAR', model.foo('foo'))
          assert_equal('BAR', model.foo(:foo))

          # Errors
          error = assert_raises(ArgumentError) { model.add_foo('', 'bar') }
          assert_equal("key can't be blank", error.message)

          assert_raises(InvalidArgumentError) { model.add_foo 'foo_bar', 'FOO' }
          assert_raises(InvalidArgumentError) { model.add_foo 'foo', 'foo_bar' }
        end

        def test_hash_attribute_with_default_value
          default_value = { 'foo' => 'bar' }

          model = Class.new do
            extend Attributes
            attribute :foos, { String => String }, default: default_value
          end.new

          assert_equal(default_value, model.foos)
        end

        def test_read_only_hash_attribute
          model = Class.new do
            extend Attributes
            attribute :foos, { String => String }, read_only: true
          end.new

          assert(model.respond_to?(:foos))
          assert(!model.respond_to?(:add_foo))
        end
      end
    end
  end
end
