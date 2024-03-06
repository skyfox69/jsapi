# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NullTest < Minitest::Test
      def test_value
        assert_nil(Null.new(Model::Schema.new).value)
      end

      def test_is_null
        assert_predicate(Null.new(Model::Schema.new), :null?)
      end

      def test_is_empty
        assert_predicate(Null.new(Model::Schema.new), :empty?)
      end
    end
  end
end
