# frozen_string_literal: true

module Jsapi
  module DSL
    class CallbacksTest < Minitest::Test
      class Dummy < Base
        include Callbacks
      end

      def test_callback
        model = define_model do
          callback 'onFoo' do
            operation '{$request.query.foo}', path: '/bar'
          end
        end
        callback = model.callback('onFoo')
        assert_predicate(callback, :present?)

        callback_operation = callback.operation('{$request.query.foo}')
        assert_equal('/bar', callback_operation.path)
      end

      def test_callback_reference
        model = define_model do
          callback ref: 'foo'
        end
        assert_equal('foo', model.callback('foo').ref)
      end

      def test_callback_reference_by_name
        model = define_model do
          callback 'foo'
        end
        assert_equal('foo', model.callback('foo').ref)
      end

      def test_callback_raises_an_exception_on_ambiguous_keywords
        assert_raises(Error) do
          define_model do
            callback 'bar', ref: 'bar' do
              operation '{$request.query.foo}', path: '/bar'
            end
          end
        end
      end

      private

      def define_model(&block)
        Meta::Operation.new.tap do |model|
          Dummy.new(model, &block)
        end
      end
    end
  end
end
