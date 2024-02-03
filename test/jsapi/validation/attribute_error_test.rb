# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validation
    class AttributeErrorTest < Minitest::Test
      def test_message
        error = AttributeError.new('foo', Error.new(:invalid))
        assert_equal('foo is invalid', error.message)
      end

      def test_message_on_nil_error
        error = AttributeError.new('foo', nil)
        assert_nil(error.message)
      end

      def test_message_on_nil_error_message
        error = AttributeError.new('foo', Error.new(nil))
        assert_nil(error.message)
      end
    end
  end
end
