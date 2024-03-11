# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ErrorTest < Minitest::Test
      def test_message
        error = Error.new(Base.new(nil), :foo)
        assert_equal('is invalid', error.message)

        error = Error.new(Base.new(nil), :foo, 'foo message')
        assert_equal('foo message', error.message)
      end

      def test_full_message
        error = Error.new(Base.new(nil), :foo)
        assert_equal("'foo' is invalid", error.full_message)

        error = Error.new(Base.new(nil), :base)
        assert_equal('is invalid', error.full_message)
      end
    end
  end
end
