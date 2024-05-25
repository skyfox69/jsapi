# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      class CallbackTest < Minitest::Test
        def test_operation
          callback = define_callback do
            operation('{$request.query.foo}', path: '/foo')
          end
          callback_operation = callback.operation('{$request.query.foo}')
          assert_equal('/foo', callback_operation.path)
        end

        def test_operation_with_block
          callback = define_callback do
            operation('{$request.query.foo}') { path '/foo' }
          end
          callback_operation = callback.operation('{$request.query.foo}')
          assert_equal('/foo', callback_operation.path)
        end

        def test_operation_raises_an_exception_on_blank_expression
          error = assert_raises(Error) do
            define_callback { operation '' }
          end
          assert_equal("expression can't be blank (at operation \"\")", error.message)
        end

        private

        def define_callback(**keywords, &block)
          Meta::OpenAPI::Callback.new(keywords).tap do |callback|
            Callback.new(callback, &block)
          end
        end
      end
    end
  end
end
