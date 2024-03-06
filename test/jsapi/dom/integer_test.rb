# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class IntegerTest < Minitest::Test
      def test_value
        schema = Meta::Schema.new(type: 'integer')
        assert_equal(0, Integer.new('0', schema).value)
      end

      def test_is_not_empty
        schema = Meta::Schema.new(type: 'integer')
        assert(!Integer.new('0', schema).empty?)
      end

      def test_conversion
        schema = Meta::Schema.new(type: 'integer', conversion: :abs)
        assert_equal(1, Integer.new('-1', schema).value)
      end
    end
  end
end
