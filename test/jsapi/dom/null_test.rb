# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NullTest < Minitest::Test
      def test_null
        assert_predicate(Null.new(Model::Schema.new), :null?)
      end

      def test_empty
        assert_predicate(Null.new(Model::Schema.new), :empty?)
      end

      def test_cast
        assert_nil(Null.new(Model::Schema.new).cast)
      end
    end
  end
end
