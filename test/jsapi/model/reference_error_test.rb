# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ReferenceErrorTest < Minitest::Test
      def test_message
        error = ReferenceError.new('foo')
        assert_equal("Reference can't be resolved: 'foo'", error.message)
      end
    end
  end
end
