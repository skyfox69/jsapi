# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class BooleanTest < Minitest::Test
      def test_empty_on_true
        assert(!Boolean.new('true', Model::Schema.new).empty?)
      end

      def test_empty_on_false
        assert(!Boolean.new('false', Model::Schema.new).empty?)
      end

      def test_value_on_true
        assert(Boolean.new('true', Model::Schema.new).value)
      end

      def test_value_on_false
        assert_equal(false, Boolean.new('false', Model::Schema.new).value)
      end
    end
  end
end
