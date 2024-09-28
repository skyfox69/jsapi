# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ErrorTest < Minitest::Test
      def test_status
        error = Error.new(RuntimeError.new, status: 500)
        assert_equal(500, error.status)
      end

      def test_to_s
        error = Error.new(RuntimeError.new('foo'))
        assert_equal('foo', error.to_s)
      end

      def test_delegates_missing_to_exception
        error_class = Class.new(RuntimeError) do
          def foo
            'bar'
          end
        end
        error = Error.new(error_class.new)
        assert_equal('bar', error.foo)
      end
    end
  end
end
