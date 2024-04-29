# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class InvalidArgumentErrorTest < Minitest::Test
      def test_message
        error = InvalidArgumentError.new('foo', nil, %w[foo bar])
        assert_equal('foo must be one of ["foo", "bar"], is nil', error.message)
      end
    end
  end
end
