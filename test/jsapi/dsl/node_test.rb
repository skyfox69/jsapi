# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      def test_method_missing
        model = Class.new(Meta::Base) do
          attribute :foo, String
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_method_missing_on_array
        model = Class.new(Meta::Base) do
          attribute :foos, [String]
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal(%w[bar], model.foos)
      end

      def test_method_missing_on_hash
        model = Class.new(Meta::Base) do
          attribute :foos, { String => String }
        end.new

        Node.new(model) { foo 'foo', 'bar' }
        assert_equal('bar', model.foo('foo'))
      end

      def test_method_missing_with_block
        model = Class.new(Meta::Base) do
          attribute :foo, (
            Class.new(Meta::Base) do
              attribute :bar, String
            end
          )
        end.new

        Node.new(model) { foo { bar 'bar' } }
        assert_equal('bar', model.foo.bar)
      end

      def test_method_missing_with_block_on_array
        model = Class.new(Meta::Base) do
          attribute :foos, [
            Class.new(Meta::Base) do
              attribute :bar, String
            end
          ]
        end.new

        Node.new(model) { foo { bar 'bar' } }
        assert_equal(%w[bar], model.foos.map(&:bar))
      end

      def test_method_missing_with_block_on_hash
        model = Class.new(Meta::Base) do
          attribute :foos, {
            String => Class.new(Meta::Base) do
              attribute :bar, String
            end
          }
        end.new

        Node.new(model) { foo('foo') { bar 'bar' } }
        assert_equal('bar', model.foo('foo').bar)
      end

      def test_respond_to
        model = Class.new(Meta::Base) do
          attribute :foo
        end.new

        node = Node.new(model)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end

      def test_raises_exception_on_unsupported_method
        model = Meta::Base.new

        error = assert_raises do
          Node.new(model) { foo 'bar' }
        end
        assert_equal('unsupported method: foo', error.message)
      end

      def test_raises_exception_on_reference_with_block
        model = Class.new(Meta::Base) do
          attribute :foo, Meta::BaseReference
        end.new

        error = assert_raises do
          Node.new(model) { foo(ref: 'bar') {} }
        end
        assert_equal(
          'reference cannot be specified together with a block (at foo)',
          error.message
        )
      end
    end
  end
end
