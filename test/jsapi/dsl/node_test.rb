# frozen_string_literal: true

module Jsapi
  module DSL
    class NodeTest < Minitest::Test
      # Scopes

      def test_scope
        klass = Class.new(Node) do
          scope :foo
        end

        model = Class.new(Meta::Base::Model) do
          attribute :foo_bar, String
        end.new

        klass.new(model) do
          foo { bar 'foo' }
        end
        assert_equal('foo', model.foo_bar)

        error = assert_raises(Error) do
          klass.new(model) do
            foo { foo_bar 'foo' }
          end
        end
        assert_equal('unsupported method: foo_bar (at foo)', error.message)
      end

      # Generic methods

      def test_generic_method_call
        model = Class.new(Meta::Base::Model) do
          attribute :foo, String
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_method_missing_call_on_array
        model = Class.new(Meta::Base::Model) do
          attribute :foos, [String]
        end.new

        Node.new(model) { foo 'bar' }
        assert_equal(%w[bar], model.foos)
      end

      def test_generic_method_call_on_hash
        model = Class.new(Meta::Base::Model) do
          attribute :foos, { String => String }
        end.new

        Node.new(model) { foo 'foo', 'bar' }
        assert_equal('bar', model.foo('foo'))
      end

      def test_generic_method_call_with_block
        model = Class.new(Meta::Base::Model) do
          attribute :foo, (
            Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          )
        end.new

        Node.new(model) do
          foo { bar 'bar' }
        end
        assert_equal('bar', model.foo.bar)
      end

      def test_generic_method_call_with_block_on_array
        model = Class.new(Meta::Base::Model) do
          attribute :foos, [
            Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          ]
        end.new

        Node.new(model) do
          foo { bar 'bar' }
        end
        assert_equal(%w[bar], model.foos.map(&:bar))
      end

      def test_generic_method_call_with_block_on_hash
        model = Class.new(Meta::Base::Model) do
          attribute :foos, {
            String => Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          }
        end.new

        Node.new(model) do
          foo('foo') { bar 'bar' }
        end
        assert_equal('bar', model.foo('foo').bar)
      end

      def test_respond_to
        model = Class.new(Meta::Base::Model) do
          attribute :foo
        end.new

        node = Node.new(model)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end

      def test_raises_exception_on_unsupported_method
        model = Meta::Base::Model.new

        error = assert_raises do
          Node.new(model) { foo 'bar' }
        end
        assert_equal('unsupported method: foo', error.message)
      end

      def test_raises_exception_on_reference_and_block
        model = Class.new(Meta::Base::Model) do
          attribute :foo, Meta::Base::Reference
        end.new

        error = assert_raises do
          Node.new(model) do
            foo(ref: 'bar') {}
          end
        end
        assert_equal(
          'reference cannot be specified together with a block (at foo)',
          error.message
        )
      end
    end
  end
end
