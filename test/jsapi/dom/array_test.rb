# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ArrayTest < Minitest::Test
      MODEL = Model::Schema.new(
        type: 'array',
        items: { type: 'string', max_length: 1 }
      )

      def test_cast
        assert_equal(%w[A B C], Array.new(%w[A B C], MODEL).cast)
      end

      def test_validate_positive
        assert_predicate(Array.new(%w[A B C], MODEL), :valid?)
      end

      def test_validate_negative
        assert_equal(2, Array.new(%w[A AA B BB], MODEL).errors.count)
      end
    end
  end
end
