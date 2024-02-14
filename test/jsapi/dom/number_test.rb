# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NumberTest < Minitest::Test
      def test_empty_on_zero
        assert(!Number.new('0.0', Model::Schema.new).empty?)
      end

      def test_value
        assert_equal(0.0, Number.new('0', Model::Schema.new).value)
      end
    end
  end
end
