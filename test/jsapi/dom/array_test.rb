# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ArrayTest < Minitest::Test
      def test_value
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })
        array = Array.new(%w[foo bar], schema, definitions)
        assert_equal(%w[foo bar], array.value)
      end

      def test_emptiness
        schema = Model::Schema.new(type: 'array', items: { type: 'string' })

        array = Array.new([], schema, definitions)
        assert_predicate(array, :empty?)

        array = Array.new(%w[foo bar], schema, definitions)
        assert(!array.empty?)
      end

      # Validation tests

      def test_validates_against_json_schema
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string' },
          max_items: 2
        )
        array = Array.new(%w[foo bar], schema, definitions)
        assert_predicate(array, :valid?)

        array = Array.new(%w[foo bar foo], schema, definitions)
        assert_predicate(array, :invalid?)
        assert_equal('Is invalid', array.errors.full_message)
      end

      def test_validates_items
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string', existence: true }
        )
        array = Array.new(%w[foo bar], schema, definitions)
        assert_predicate(array, :valid?)

        array = Array.new(['foo', nil], schema, definitions)
        assert_predicate(array, :invalid?)
        assert_equal("Can't be blank", array.errors.full_message)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end
    end
  end
end
