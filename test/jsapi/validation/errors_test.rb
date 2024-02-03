# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Validation
    class ErrorsTest < Minitest::Test
      def test_full_message
        assert_equal('Foo is invalid. Bar is invalid', errors.full_message)
      end

      def test_full_message_on_nil_messages
        Error.stub_any_instance(:message, nil) do
          assert_equal('', errors.full_message)
        end
      end

      def test_full_messages
        assert_equal(['Foo is invalid', 'Bar is invalid'], errors.full_messages)
      end

      def test_full_messages_on_nil_messages
        Error.stub_any_instance(:message, nil) do
          assert_equal([], errors.full_messages)
        end
      end

      def test_to_json
        assert_equal('Foo is invalid. Bar is invalid', errors.to_json)
      end

      private

      def errors
        Errors.new.tap do |errors|
          errors << AttributeError.new('foo', Error.new(:invalid))
          errors << AttributeError.new('bar', Error.new(:invalid))
        end
      end
    end
  end
end
