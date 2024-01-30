# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validation
    class AttributeErrorTest < Minitest::Test
      def test_message
        error = AttributeError.new('foo', Error.new(:invalid))
        assert_equal('foo is invalid', error.message)
      end
    end
  end
end
