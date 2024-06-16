# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class RescueHandlerTest < Minitest::Test
      def test_status_on_standard_error
        rescue_handler = RescueHandler.new(StandardError, status: 500)
        assert_equal(500, rescue_handler.status)
      end

      def test_status_on_subclass_of_standard_error
        rescue_handler = RescueHandler.new(RuntimeError, status: 500)
        assert_equal(500, rescue_handler.status)
      end

      def test_raises_an_exception_on_other_object_than_a_class
        error = assert_raises(ArgumentError) { RescueHandler.new('foo') }
        assert_equal('"foo" must be a standard error class', error.message)
      end

      def test_raises_an_exception_on_other_error_class
        error = assert_raises(ArgumentError) { RescueHandler.new(Exception) }
        assert_equal('Exception must be a standard error class', error.message)
      end

      def test_inspect
        assert_equal(
          '#<Jsapi::Meta::RescueHandler class: StandardError, status: "default">',
          RescueHandler.new(StandardError).inspect
        )
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
