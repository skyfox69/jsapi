# frozen_string_literal: true

module Jsapi
  module Meta
    module Model
      class AttributesTest < Minitest::Test
        class Dummy < Base
          attr_reader :last_changed

          protected

          def attribute_changed(name)
            @last_changed = name
          end
        end

        def test_attribute_names
          foo_class = Class.new(Dummy) do
            attribute :foo
          end
          assert_equal(%i[foo], foo_class.attribute_names)

          bar_class = Class.new(foo_class) do
            attribute :bar
          end
          assert_equal(%i[foo bar], bar_class.attribute_names)
        end

        def test_responds_to_accessors
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, Object
            end.new,
            to: %i[foo foo=]
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, Object, accessors: %i[reader]
            end.new,
            to: :foo,
            not_to: :foo=
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, Object, accessors: %i[writer]
            end.new,
            to: :foo=,
            not_to: :foo
          )
        end

        def test_attribute_reader_and_writer
          model = Class.new(Dummy) do
            attribute :foo, Object, values: %w[foo]
          end.new

          model.foo = 'foo'
          assert_equal('foo', model.foo)
          assert_equal(:foo, model.last_changed)

          # Errors
          error = assert_raises(InvalidArgumentError) do
            model.foo = 'bar'
          end
          assert_equal('foo must be "foo", is "bar"', error.message)
        end

        def test_default_value
          model = Class.new(Dummy) do
            attribute :foo, Object, default: 'bar'
          end.new

          assert_equal('bar', model.foo)
        end

        # Boolean attributes

        def test_responds_to_accessors_on_boolean
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, values: [true, false]
            end.new,
            to: %i[foo foo? foo=]
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, values: [true, false], accessors: %i[reader]
            end.new,
            to: %i[foo foo?],
            not_to: :foo=
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foo, values: [true, false], accessors: %i[writer]
            end.new,
            to: :foo=,
            not_to: %i[foo foo?]
          )
        end

        def test_predicate_method_on_boolean
          model = Class.new(Dummy) do
            attribute :foo, values: [true, false]
          end.new

          model.foo = true
          assert(model.foo?)

          model.foo = false
          assert(!model.foo?)
        end

        def test_predicate_method_on_true_by_default
          model = Class.new(Dummy) do
            attribute :foo, values: [true, false], default: true
          end.new

          assert(model.foo?)
        end

        # Array attributes

        def test_responds_to_accessors_on_array
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, []
            end.new,
            to: %i[foos foos= add_foo]
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, [], accessors: %i[reader writer]
            end.new,
            to: %i[foos foos=],
            not_to: :add_foo
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, [], accessors: %i[add reader]
            end.new,
            to: %i[foos add_foo],
            not_to: :foos=
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, [], accessors: %i[add writer]
            end.new,
            to: %i[foos= add_foo],
            not_to: :foos
          )
        end

        def test_attribute_reader_and_writer_on_array
          model = Class.new(Dummy) do
            attribute :foos, [], values: %w[foo bar]
          end.new

          assert_equal([], model.foos)

          array = %w[foo bar]
          result = model.foos = array
          assert_equal(array, result)
          assert_equal(array, model.foos)

          assert_equal(:foos, model.last_changed)

          # Errors
          error = assert_raises(InvalidArgumentError) do
            model.foos = %w[foo_bar]
          end
          assert_equal('foo must be one of "foo" or "bar", is "foo_bar"', error.message)
        end

        def test_add_method_on_array
          model = Class.new(Dummy) do
            attribute :foos, [], values: %w[foo]
          end.new

          model.add_foo('foo')
          assert_equal(%w[foo], model.foos)

          # Errors
          error = assert_raises(InvalidArgumentError) do
            model.add_foo('bar')
          end
          assert_equal('foo must be "foo", is "bar"', error.message)
        end

        def test_default_value_on_array
          default_value = %w[foo bar]

          model = Class.new(Dummy) do
            attribute :foos, [], default: default_value
          end.new

          assert_equal(default_value, model.foos)
        end

        def test_read_only_on_array
          model = Class.new(Dummy) do
            attribute :foos, [String], accessors: %i[reader]
          end.new

          assert(!model.respond_to?(:foos=))
          assert(!model.respond_to?(:add_foo))
        end

        # Hash attributes

        def test_responds_to_accessors_on_hash
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, {}
            end.new,
            to: %i[foo foos foos= add_foo]
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, {}, accessors: %i[reader writer]
            end.new,
            to: %i[foo foos foos=],
            not_to: :add_foo
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, {}, accessors: %i[add reader]
            end.new,
            to: %i[foo foos add_foo],
            not_to: :foos=
          )
          assert_responds(
            Class.new(Dummy) do
              attribute :foos, {}, accessors: %i[add writer]
            end.new,
            to: %i[foos= add_foo],
            not_to: %i[foo foos]
          )
        end

        def test_attribute_reader_and_writer_on_hash
          model = Class.new(Dummy) do
            attribute :foos, {}, keys: %w[foo], values: %w[bar]
          end.new

          assert_equal({}, model.foos)

          hash = { 'foo' => 'bar' }
          result = model.foos = hash
          assert_equal(hash, result)
          assert_equal(hash, model.foos)

          assert_equal(:foos, model.last_changed)

          # Errors
          error = assert_raises(ArgumentError) do
            model.foos = { '' => 'bar' }
          end
          assert_equal("key can't be blank", error.message)

          error = assert_raises(InvalidArgumentError) do
            model.foos = { 'bar' => 'bar' }
          end
          assert_equal('key must be "foo", is "bar"', error.message)

          error = assert_raises(InvalidArgumentError) do
            model.foos = { 'foo' => 'foo' }
          end
          assert_equal('value must be "bar", is "foo"', error.message)
        end

        def test_add_method_on_hash
          model = Class.new(Dummy) do
            attribute :foos, {}, keys: %w[foo], values: %w[bar]
          end.new

          model.add_foo('foo', 'bar')
          assert_equal({ 'foo' => 'bar' }, model.foos)

          # Errors
          error = assert_raises(ArgumentError) do
            model.add_foo('', 'bar')
          end
          assert_equal("key can't be blank", error.message)

          error = assert_raises(InvalidArgumentError) do
            model.add_foo 'bar', 'bar'
          end
          assert_equal('key must be "foo", is "bar"', error.message)

          error = assert_raises(InvalidArgumentError) do
            model.add_foo 'foo', 'foo'
          end
          assert_equal('value must be "bar", is "foo"', error.message)
        end

        def test_add_method_on_default_key
          model = Class.new(Dummy) do
            attribute :foos, {}, default_key: 'bar'
          end.new

          model.add_foo('foo')
          assert_equal({ 'bar' => 'foo' }, model.foos)
        end

        def test_lockup_method_on_hash
          model = Class.new(Dummy) do
            attribute :foos, {}
          end.new

          model.add_foo('foo', 'bar')
          assert_equal('bar', model.foo('foo'))

          assert_nil(model.foo(nil))
        end

        def test_default_value_on_hash
          default_value = { 'foo' => 'bar' }

          model = Class.new(Dummy) do
            attribute :foos, {}, default: default_value
          end.new

          assert_equal(default_value, model.foos)
        end

        def test_read_only_on_hash
          model = Class.new(Dummy) do
            attribute :foos, {}, accessors: %i[reader]
          end.new

          assert(!model.respond_to?(:foo=))
          assert(!model.respond_to?(:add_foo))
        end

        private

        def assert_responds(model, to: [], not_to: [])
          Array(to).each { |method| assert(model.respond_to?(method)) }
          Array(not_to).each { |method| assert(!model.respond_to?(method)) }
        end
      end
    end
  end
end
