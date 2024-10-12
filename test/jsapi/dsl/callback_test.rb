# frozen_string_literal: true

module Jsapi
  module DSL
    class CallbackTest < Minitest::Test
      # #operation

      def test_operation
        operation = callback do
          operation '{$request.query.foo}', description: 'Lorem ipsum'
        end.operation('{$request.query.foo}')

        assert_predicate(operation, :present?)
        assert_equal('Lorem ipsum', operation.description)
      end

      def test_operation_with_block
        operation = callback do
          operation '{$request.query.foo}' do
            description 'Lorem ipsum'
          end
        end.operation('{$request.query.foo}')

        assert_predicate(operation, :present?)
        assert_equal('Lorem ipsum', operation.description)
      end

      def test_operation_raises_an_exception_on_blank_expression
        error = assert_raises(Error) do
          callback do
            operation ''
          end
        end
        assert_equal("expression can't be blank (at operation \"\")", error.message)
      end

      private

      def callback(**keywords, &block)
        Meta::Callback.new(keywords).tap do |callback|
          Callback.new(callback, &block)
        end
      end
    end
  end
end
