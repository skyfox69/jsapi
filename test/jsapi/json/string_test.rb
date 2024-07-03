# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module JSON
    class StringTest < Minitest::Test
      def test_value_on_default_format
        schema = Meta::Schema.new(type: 'string')
        string = String.new('foo', schema)
        assert_equal('foo', string.value)
      end

      def test_value_on_conversion
        schema = Meta::Schema.new(type: 'string', conversion: :upcase)
        assert_equal('FOO', String.new('foo', schema).value)
      end

      def test_value_and_validity_on_date_format
        schema = Meta::Schema.new(type: 'string', format: 'date')
        errors = Model::Errors.new

        # valid value
        string = String.new('2099-12-31', schema)
        assert_equal(Date.new(2099, 12, 31), string.value)
        assert(string.validate(errors))
        assert(errors.empty?)

        # invalid value
        string = String.new('foo', schema)
        assert_equal('foo', string.value)
        assert(!string.validate(errors))
        assert(errors.added?(:base, :invalid))
      end

      def test_value_and_validity_on_date_time_format
        schema = Meta::Schema.new(type: 'string', format: 'date-time')
        errors = Model::Errors.new

        # valid value
        string = String.new('2099-12-31', schema)
        assert_equal(DateTime.new(2099, 12, 31), string.value)
        assert(string.validate(errors))
        assert(errors.empty?)

        # invalid value
        string = String.new('foo', schema)
        assert_equal('foo', string.value)
        assert(!string.validate(errors))
        assert(errors.added?(:base, :invalid))
      end

      def test_value_and_validity_on_duration_format
        schema = Meta::Schema.new(type: 'string', format: 'duration')
        errors = Model::Errors.new

        # valid value
        string = String.new('P1D', schema)
        assert_equal(ActiveSupport::Duration.build(86_400), string.value)
        assert(string.validate(errors))
        assert(errors.empty?)

        # invalid value
        string = String.new('foo', schema)
        assert_equal('foo', string.value)
        assert(!string.validate(errors))
        assert(errors.added?(:base, :invalid))
      end

      def test_empty_predicate
        schema = Meta::Schema.new(type: 'string')
        assert_predicate(String.new('', schema), :empty?)
        assert(!String.new('foo', schema).empty?)
      end
    end
  end
end
