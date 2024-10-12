# frozen_string_literal: true

module Jsapi
  module DSL
    class BaseTest < Minitest::Test
      # #initialize

      def test_initialize_raises_an_exception_on_reference_and_block
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foo, Meta::Base::Reference
        end.new

        error = assert_raises(Error) do
          Base.new(meta_model) do
            foo(ref: 'bar') {}
          end
        end
        assert_equal(
          "reference can't be specified together with a block (at foo)",
          error.message
        )
      end

      # Keywords

      def test_keyword
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foo, String
        end.new

        Base.new(meta_model) { foo 'bar' }
        assert_equal('bar', meta_model.foo)
      end

      def test_keyword_on_array_attribute
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foos, [String]
        end.new

        Base.new(meta_model) { foo 'bar' }
        assert_equal(%w[bar], meta_model.foos)
      end

      def test_keyword_on_hash_attribute
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foos, { String => String }
        end.new

        Base.new(meta_model) { foo 'foo', 'bar' }
        assert_equal('bar', meta_model.foo('foo'))
      end

      def test_keyword_with_block
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foo, (
            Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          )
        end.new

        Base.new(meta_model) do
          foo { bar 'bar' }
        end
        assert_equal('bar', meta_model.foo.bar)
      end

      def test_keyword_with_block_on_array_attribute
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foos, [
            Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          ]
        end.new

        Base.new(meta_model) do
          foo { bar 'bar' }
        end
        assert_equal(%w[bar], meta_model.foos.map(&:bar))
      end

      def test_keyword_with_block_on_hash_attribute
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foos, {
            String => Class.new(Meta::Base::Model) do
              attribute :bar, String
            end
          }
        end.new

        Base.new(meta_model) do
          foo('foo') { bar 'bar' }
        end
        assert_equal('bar', meta_model.foo('foo').bar)
      end

      def test_raises_an_exception_on_unsupported_keyword
        meta_model = Meta::Base::Model.new

        error = assert_raises(RuntimeError) do
          Base.new(meta_model) { foo 'bar' }
        end
        assert_equal('unsupported keyword: foo', error.message)
      end

      # #respond_to?

      def test_respond_to
        meta_model = Class.new(Meta::Base::Model) do
          attribute :foo
        end.new

        base = Base.new(meta_model)
        assert(base.respond_to?(:foo))
        assert(!base.respond_to?(:bar))
      end
    end
  end
end
