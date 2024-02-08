# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class StringTest < Minitest::Test
      def test_cast
        schema = Model::Schema.new(type: 'string')
        string = String.new('foo', schema)

        assert_equal('foo', string.cast)
      end

      def test_cast_on_date
        schema = Model::Schema.new(type: 'string', format: 'date')
        string = String.new('2099-12-31', schema)

        assert_equal(Date.new(2099, 12, 31), string.cast)
      end

      def test_cast_on_date_time
        schema = Model::Schema.new(type: 'string', format: 'date-time')
        string = String.new('2099-12-31', schema)

        assert_equal(DateTime.new(2099, 12, 31), string.cast)
      end
    end
  end
end
