# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      def test_method_missing
        dummy = Class.new do
          attr_accessor :foo
        end.new
        Node.new(dummy).call { foo 'bar' }
        assert_equal('bar', dummy.foo)
      end

      def test_method_missing_on_array
        dummy = Class.new do
          attr_reader :foos

          def add_foo(value)
            (@foos ||= []) << value
          end
        end.new
        Node.new(dummy).call { foo 'bar' }
        assert_equal(%w[bar], dummy.foos)
      end

      def test_method_missing_on_hash
        dummy = Class.new do
          attr_reader :foos

          def add_foo(key, value)
            (@foos ||= {})[key] = value
          end
        end.new
        Node.new(dummy).call { foo 'foo', 'bar' }
        assert_equal('bar', dummy.foos['foo'])
      end

      def test_method_missing_with_block
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

      def test_method_missing_with_block_on_array
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

      def test_method_missing_with_block_on_hash
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

      def test_respond_to
        dummy = Class.new do
          attr_writer :foo
        end.new
        node = Node.new(dummy)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end

      def test_raises_exception_on_unsupported_method
        node = Node.new(Class.new { attr_writer :foo }.new)
        error = assert_raises do
          node.call { bar 'foo' }
        end
        assert_equal('unsupported method: bar', error.message)

        error = assert_raises do
          node.call { foo('bar') { bar 'foo' } }
        end
        assert_equal('unsupported method: bar (at foo)', error.message)
      end
    end
  end
end
