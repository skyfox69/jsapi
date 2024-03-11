# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ErrorTest < Minitest::Test
      def test_message
        error = Error.new(self, :foo)
        assert_equal('is invalid', error.message)

        error = Error.new(self, :foo, 'bar')
        assert_equal('bar', error.message)
      end

      def test_full_message
        error = Error.new(self, :foo)
        assert_equal('foo is invalid', error.full_message)

        error = Error.new(self, :base)
        assert_equal('is invalid', error.full_message)
      end
    end
  end
end
