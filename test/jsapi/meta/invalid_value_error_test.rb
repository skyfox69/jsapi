# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class InvalidValueErrorTest < Minitest::Test
      def test_message
        error = InvalidValueError.new('foo', 'bar')
        assert_equal('foo must not be "bar"', error.message)
      end
    end
  end
end
