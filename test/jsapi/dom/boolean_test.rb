# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class BooleanTest < Minitest::Test
      def test_value
        assert(Boolean.new('true', Model::Schema.new).value)
        assert_equal(false, Boolean.new('false', Model::Schema.new).value)
      end

      def test_is_not_empty
        assert(!Boolean.new('true', Model::Schema.new).empty?)
        assert(!Boolean.new('false', Model::Schema.new).empty?)
      end
    end
  end
end
