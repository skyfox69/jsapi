# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class BooleanTest < Minitest::Test
      def test_value
        assert(Boolean.new('true', Meta::Schema.new).value)
        assert_equal(false, Boolean.new('false', Meta::Schema.new).value)
      end

      def test_empty_predicate
        assert(!Boolean.new('true', Meta::Schema.new).empty?)
        assert(!Boolean.new('false', Meta::Schema.new).empty?)
      end
    end
  end
end
