# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NumberTest < Minitest::Test
      def test_cast
        assert_equal(0.0, Number.new('0', Model::Schema.new).cast)
      end
    end
  end
end
