# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ErrorResultTest < Minitest::Test
      def test_status
        error_result = ErrorResult.new(RuntimeError.new, status: 500)
        assert_equal(500, error_result.status)
      end

      def test_to_s
        error_result = ErrorResult.new(RuntimeError.new('foo'))
        assert_equal('foo', error_result.to_s)
      end

      def test_delegates_missing_to_exception
        error_class = Class.new(RuntimeError) do
          def foo
            'bar'
          end
        end
        error_result = ErrorResult.new(error_class.new)
        assert_equal('bar', error_result.foo)
      end
    end
  end
end
