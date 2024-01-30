# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class IntegerTest < Minitest::Test
      def test_cast
        assert_equal(0, Integer.new('0', Model::Schema.new).cast)
      end
    end
  end
end
