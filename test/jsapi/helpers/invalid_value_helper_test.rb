# frozen_string_literal: true

require 'test_helper'

module Jsapi
  class InvalidValueHelperTest < Minitest::Test
    include InvalidValueHelper

    def test_build_message
      assert_equal(
        'foo must not be "bar"',
        build_message('foo', 'bar', [])
      )
      assert_equal(
        'foo must be "bar", is nil',
        build_message('foo', nil, %w[bar])
      )
      assert_equal(
        'foo must be one of "foo" or "bar", is nil',
        build_message('foo', nil, %w[foo bar])
      )
    end
  end
end
