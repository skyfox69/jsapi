# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validation
    class ErrorsTest < Minitest::Test
      def test_full_message
        errors = Errors.new
        errors << AttributeError.new('foo', Error.new(:invalid))
        errors << AttributeError.new('bar', Error.new(:invalid))

        assert_equal('Foo is invalid. Bar is invalid', errors.full_message)
      end

      def test_full_messages
        errors = Errors.new
        errors << AttributeError.new('foo', Error.new(:invalid))
        errors << AttributeError.new('bar', Error.new(:invalid))

        assert_equal(['Foo is invalid', 'Bar is invalid'], errors.full_messages)
      end
    end
  end
end
