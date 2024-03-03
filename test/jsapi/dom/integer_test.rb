# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class IntegerTest < Minitest::Test
      def test_empty_on_zero
        schema = Model::Schema.new(type: 'integer')
        assert(!Integer.new('0', schema).empty?)
      end

      def test_value
        schema = Model::Schema.new(type: 'integer')
        assert_equal(0, Integer.new('0', schema).value)
      end

      def test_conversion
        schema = Model::Schema.new(type: 'integer', conversion: :abs)
        assert_equal(1, Integer.new('-1', schema).value)
      end
    end
  end
end
