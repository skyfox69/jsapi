# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class RescueHandlerTest < Minitest::Test
      def test_raises_an_exception_on_invalid_argument
        error = assert_raises(ArgumentError) { RescueHandler.new('foo') }
        assert_equal('"foo" must be a standard error class', error.message)
      end

      def test_match
        rescue_handler = RescueHandler.new(StandardError)

        assert(rescue_handler.match?(StandardError.new))
        assert(rescue_handler.match?(RuntimeError.new))

        assert(!rescue_handler.match?(Exception.new))
      end
    end
  end
end
