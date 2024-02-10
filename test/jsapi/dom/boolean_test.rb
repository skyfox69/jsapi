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

      def test_cast_true
        assert(Boolean.new('true', Model::Schema.new).cast)
      end

      def test_cast_false
        assert_equal(false, Boolean.new('false', Model::Schema.new).cast)
      end
    end
  end
end
