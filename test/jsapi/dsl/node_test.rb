# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      def test_generic_keyword
        dummy = Class.new do
          attr_accessor :foo
        end.new
        Node.new(dummy).call { foo 'bar' }
        assert_equal('bar', dummy.foo)
      end

      def test_generic_keyword_with_block
        dummy = Class.new do
          attr_reader :foo

          def foo=(*)
            @foo = Class.new do
              attr_accessor :bar
            end.new
          end
        end.new
        Node.new(dummy).call do
          foo { bar 'bar' }
        end
        assert_equal('bar', dummy.foo.bar)
      end

      def test_generic_array_keyword
        dummy = Class.new do
          attr_reader :foos

          def add_foo(value)
            (@foos ||= []) << value
          end
        end.new
        Node.new(dummy).call { foo 'bar' }
        assert_equal(%w[bar], dummy.foos)
      end

      def test_generic_array_keyword_with_block
        dummy = Class.new do
          attr_reader :foos

          def add_foo(*)
            foo = Class.new do
              attr_accessor :bar
            end.new
            (@foos ||= []) << foo
            foo
          end
        end.new
        Node.new(dummy).call do
          foo { bar 'bar' }
        end
        assert_equal(%w[bar], dummy.foos.map(&:bar))
      end

      def test_generic_hash_keyword
        dummy = Class.new do
          attr_reader :foos

          def add_foo(key, value)
            (@foos ||= {})[key] = value
          end
        end.new
        Node.new(dummy).call { foo 'foo', 'bar' }
        assert_equal('bar', dummy.foos['foo'])
      end

      def test_generic_hash_keyword_with_block
        dummy = Class.new do
          attr_reader :foos

          def add_foo(key)
            foo = Class.new do
              attr_accessor :bar
            end.new
            (@foos ||= {})[key] = foo
          end
        end.new
        Node.new(dummy).call do
          foo('foo') { bar 'bar' }
        end
        assert_equal('bar', dummy.foos['foo'].bar)
      end

      def test_raises_exception_on_invalid_keyword
        node = Node.new(Class.new.new)
        error = assert_raises do
          node.call { foo 'bar' }
        end
        assert_equal("invalid keyword: 'foo'", error.message)
      end

      def test_raises_exception_on_invalid_nested_keyword
        node = Node.new(Class.new { attr_writer :foo }.new)
        error = assert_raises do
          node.call { foo('bar') { bar 'foo' } }
        end
        assert_equal("invalid keyword: 'bar' (at foo)", error.message)
      end

      def test_respond_to
        dummy = Class.new do
          attr_writer :foo
        end.new
        node = Node.new(dummy)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end
    end
  end
end
