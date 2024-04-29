# frozen_string_literal: true

module Jsapi
  module Meta
    module Attributes
      class ClassMethodsTest < Minitest::Test
        extend ClassMethods

        def teardown
          klass = self.class

          %i[foo foo? foo= foos foos= add_foo].each do |name|
            klass.undef_method name if klass.method_defined?(name)
          end
        end

        # Defined methods tests

        def test_defined_methods_on_writable_attribute
          self.class.attribute(:foo, String)
          assert(respond_to?(:foo))
          assert(respond_to?(:foo=))
        end

        def test_defined_methods_on_read_only_attribute
          self.class.attribute(:foo, String, writer: false)
          assert(respond_to?(:foo))
          assert(!respond_to?(:foo=))
        end

        def test_defined_methods_on_writable_boolean_attribute
          self.class.attribute(:foo, values: [true, false])
          assert(respond_to?(:foo))
          assert(respond_to?(:foo?))
          assert(respond_to?(:foo=))
        end

        def test_defined_methods_on_read_only_boolean_attribute
          self.class.attribute(:foo, values: [true, false], writer: false)
          assert(respond_to?(:foo))
          assert(respond_to?(:foo?))
          assert(!respond_to?(:foo=))
        end

        def test_defined_methods_on_writable_array_attribute
          self.class.attribute(:foos, [String])
          assert(respond_to?(:foos))
          assert(respond_to?(:foos=))
          assert(respond_to?(:add_foo))
        end

        def test_defined_methods_on_read_only_array_attribute
          self.class.attribute(:foos, [String], writer: false)
          assert(respond_to?(:foos))
          assert(!respond_to?(:foos=))
          assert(!respond_to?(:add_foo))
        end

        def test_defined_methods_on_writable_hash_attribute
          self.class.attribute(:foos, { String => String })
          assert(respond_to?(:foos))
          assert(respond_to?(:add_foo))
        end

        def test_defined_methods_on_read_only_hash_attribute
          self.class.attribute(:foos, { String => String }, writer: false)
          assert(respond_to?(:foos))
          assert(!respond_to?(:add_foo))
        end

        # Attribute reader and writer tests

        def test_attr_reader_and_writer
          self.class.attribute(:foo, String)
          assert_nil(foo)

          self.foo = 'bar'
          assert_equal('bar', foo)

          self.foo = nil
          assert_nil(foo)
        end

        def test_predicate_method
          self.class.attribute(:foo, values: [true, false])
          assert(!foo?)

          self.foo = true
          assert(foo?)

          self.foo = false
          assert(!foo?)
        end

        def test_attr_reader_on_default_value
          self.class.attribute(:foo, String, default: 'bar')
          assert_equal('bar', foo)
        end

        def test_attr_writer_raises_an_exception_on_invalid_value
          self.class.attribute(:foo, values: %w[foo bar])
          assert_raises(InvalidArgumentError) { self.foo = 'foo_bar' }
        end

        # Array attributes tests

        def test_array_attr_writer
          self.class.attribute(:foos, [String])
          self.foos = %w[foo bar]
          assert_equal(%w[foo bar], foos)
        end

        def test_array_attr_writer_raises_an_exception_on_invalid_element
          self.class.attribute(:foos, [String], values: %w[foo bar])
          assert_raises(InvalidArgumentError) { self.foos = %w[foo foo_bar] }
        end

        def test_add_to_array
          self.class.attribute(:foos, [String])
          assert_nil(foos)

          assert_equal('bar', add_foo('bar'))
          assert_equal('bar', foos.last)
        end

        def test_add_to_array_raises_an_exception_on_invalid_element
          self.class.attribute(:foos, [String], values: %w[foo bar])
          assert_raises(InvalidArgumentError) { add_foo 'foo_bar' }
        end

        # Hash attributes tests

        def test_hash_value_reader
          self.class.attribute(:foos, { String => String })
          assert_nil(foo('foo'))

          add_foo('foo', 'bar')
          assert_equal('bar', foo('foo'))
          assert_equal('bar', foo(:foo))
        end

        def test_add_to_hash
          self.class.attribute(:foos, { String => String })
          assert_nil(foos)

          assert_equal('bar', add_foo('foo', 'bar'))
          assert_equal('bar', foos['foo'])
        end

        def test_add_to_hash_raises_an_exception_on_blank_key
          self.class.attribute(:foos, { String => String })
          error = assert_raises(ArgumentError) { add_foo('', 'bar') }
          assert_equal("key can't be blank", error.message)
        end

        def test_add_to_hash_raises_an_exception_on_invalid_key
          self.class.attribute(:foos, { String => String }, keys: %w[foo bar])
          assert_raises(InvalidArgumentError) { add_foo 'foo_bar', '' }
        end

        def test_add_to_hash_raises_an_exception_on_invalid_value
          self.class.attribute(:foos, { String => String }, values: %w[foo bar])
          assert_raises(InvalidArgumentError) { add_foo 'foo', 'foo_bar' }
        end

        # attribute names tests

        def test_attribute_names
          foo_class = Class.new do
            extend ClassMethods
            attribute :foo
          end
          bar_class = Class.new(foo_class) do
            attribute :bar
          end
          assert_equal(%i[foo], foo_class.attribute_names)
          assert_equal(%i[foo bar], bar_class.attribute_names)
        end
      end
    end
  end
end
