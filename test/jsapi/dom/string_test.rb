# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class StringTest < Minitest::Test
      def test_empty_on_absence
        schema = Model::Schema.new(type: 'string')
        assert_predicate(String.new('', schema), :empty?)
      end

      def test_empty_on_presence
        schema = Model::Schema.new(type: 'string')
        assert(!String.new('foo', schema).empty?)
      end

      def test_value
        schema = Model::Schema.new(type: 'string')
        string = String.new('foo', schema)

        assert_equal('foo', string.value)
      end

      def test_value_on_date
        schema = Model::Schema.new(type: 'string', format: 'date')
        string = String.new('2099-12-31', schema)
        assert_equal(Date.new(2099, 12, 31), string.value)
      end

      def test_value_on_date_time
        schema = Model::Schema.new(type: 'string', format: 'date-time')
        string = String.new('2099-12-31', schema)
        assert_equal(DateTime.new(2099, 12, 31), string.value)
      end

      def test_conversion
        schema = Model::Schema.new(type: 'string', conversion: :upcase)
        assert_equal('FOO', String.new('foo', schema).value)
      end
    end
  end
end
