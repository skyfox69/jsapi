# frozen_string_literal: true

module Jsapi
  module DSL
    class BaseTest < Minitest::Test
      # Generic methods

      def test_generic_method_call
        model = Class.new(Meta::Base::Model) do
          attribute :foo, String
        end.new

        Base.new(model) { foo 'bar' }
        assert_equal('bar', model.foo)
      end

      def test_method_missing_call_on_array
        model = Class.new(Meta::Base::Model) do
          attribute :foos, [String]
        end.new

        Base.new(model) { foo 'bar' }
        assert_equal(%w[bar], model.foos)
      end

      def test_generic_method_call_on_hash
        model = Class.new(Meta::Base::Model) do
          attribute :foos, { String => String }
        end.new

        Base.new(model) { foo 'foo', 'bar' }
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

        Base.new(model) do
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

        Base.new(model) do
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

        Base.new(model) do
          foo('foo') { bar 'bar' }
        end
        assert_equal('bar', model.foo('foo').bar)
      end

      def test_respond_to
        model = Class.new(Meta::Base::Model) do
          attribute :foo
        end.new

        node = Base.new(model)
        assert(node.respond_to?(:foo))
        assert(!node.respond_to?(:bar))
      end

      def test_raises_an_exception_on_unsupported_method
        model = Meta::Base::Model.new

        error = assert_raises do
          Base.new(model) { foo 'bar' }
        end
        assert_equal('unsupported method: foo', error.message)
      end

      def test_raises_an_exception_on_reference_and_block
        model = Class.new(Meta::Base::Model) do
          attribute :foo, Meta::Base::Reference
        end.new

        error = assert_raises do
          Base.new(model) do
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
