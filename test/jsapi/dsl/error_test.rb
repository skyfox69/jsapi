# frozen_string_literal: true

module Jsapi
  module DSL
    class ErrorTest < Minitest::Test
      def test_message
        error = Error.new(RuntimeError.new('message'), 'foo')
        assert_equal('message (at foo)', error.message)
      end

      def test_message_on_blank_origin
        error = Error.new(RuntimeError.new('message'))
        assert_equal('message', error.message)
      end

      def test_prepend_origin
        error = Error.new(RuntimeError.new('message'), 'bar').prepend_origin('foo')
        assert_equal('message (at foo/bar)', error.message)
      end

      def test_prepend_origin_on_nil
        error = Error.new(RuntimeError.new('message'), 'bar').prepend_origin('')
        assert_equal('message (at bar)', error.message)
      end
    end
  end
end
