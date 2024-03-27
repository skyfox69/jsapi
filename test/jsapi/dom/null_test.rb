# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NullTest < Minitest::Test
      def test_value
        assert_nil(Null.new(Meta::Schema.new).value)
      end

      def test_null_predicate
        assert_predicate(Null.new(Meta::Schema.new), :null?)
      end

      def test_empty_predicate
        assert_predicate(Null.new(Meta::Schema.new), :empty?)
      end

      # inspect

      def test_inspect
        assert_equal('#<Jsapi::DOM::Null>', Null.new(Meta::Schema.new).inspect)
      end
    end
  end
end
