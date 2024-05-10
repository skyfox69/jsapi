# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      def test_method_missing
        model = Class.new do
          attr_accessor :foo
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_method_missing_on_array
        model = Class.new do
          attr_reader :foos

          def add_foo(value)
            (@foos ||= []) << value
          end
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal(%w[bar], model.foos)
      end

      def test_method_missing_on_hash
        model = Class.new do
          attr_reader :foos

          def add_foo(key, value)
            (@foos ||= {})[key] = value
          end
        end.new

        Node.new(model) { foo 'foo', 'bar' }
        assert_equal('bar', model.foos['foo'])
      end

      def test_method_missing_with_block
        model = Class.new do
          attr_reader :foo

          def foo=(*)
            @foo = Class.new do
              attr_accessor :bar
            end.new
          end
        end.new

        Node.new(model) do
          foo { bar 'bar' }
        end
        assert_equal('bar', model.foo.bar)
      end

      def test_method_missing_with_block_on_array
        model = Class.new do
          attr_reader :foos

          def add_foo(*)
            foo = Class.new do
              attr_accessor :bar
            end.new
            (@foos ||= []) << foo
            foo
          end
        end.new

        Node.new(model) do
          foo { bar 'bar' }
        end
        assert_equal(%w[bar], model.foos.map(&:bar))
      end

      def test_method_missing_with_block_on_hash
        model = Class.new do
          attr_reader :foos

          def add_foo(key)
            foo = Class.new do
              attr_accessor :bar
            end.new
            (@foos ||= {})[key] = foo
          end
        end.new

        Node.new(model) do
          foo('foo') { bar 'bar' }
        end
        assert_equal('bar', model.foos['foo'].bar)
      end

      def test_respond_to
        model = Class.new do
          attr_writer :foo
        end.new

        node = Node.new(model)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end

      def test_raises_exception_on_unsupported_method
        model = Class.new do
          attr_writer :foo
        end.new

        error = assert_raises do
          Node.new(model) { bar 'foo' }
        end
        assert_equal('unsupported method: bar', error.message)

        error = assert_raises do
          Node.new(model) { foo('bar') { bar 'foo' } }
        end
        assert_equal('unsupported method: bar (at foo)', error.message)
      end
    end
  end
end
