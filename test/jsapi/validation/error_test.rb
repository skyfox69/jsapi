# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validation
    class ErrorTest < Minitest::Test
      def test_message
        error = Error.new(:invalid)
        assert_equal('is invalid', error.message)
      end

      def test_message_with_options
        error = Error.new(:greater_than, count: 0)
        assert_equal('must be greater than 0', error.message)
      end

      def test_message_on_nil_message
        error = Error.new(nil)
        assert_nil(error.message)
      end
    end
  end
end
