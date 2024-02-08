# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class NullTest < Minitest::Test
      def test_cast
        assert_nil(Null.new(Model::Schema.new).cast)
      end

      def test_validate_positive
        null = Null.new(Model::Schema.new(existence: false))
        assert_predicate(null, :valid?)
      end

      def test_validate_negative
        null = Null.new(Model::Schema.new(existence: true))
        assert_predicate(null.errors, :one?)
      end
    end
  end
end
