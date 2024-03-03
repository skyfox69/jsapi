# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ArrayTest < Minitest::Test
      def test_empty_on_absence
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string' }
        )
        array = Array.new([], schema, definitions)
        assert_predicate(array, :empty?)
      end

      def test_empty_on_presence
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string' }
        )
        array = Array.new(%w[foo bar], schema, definitions)
        assert(!array.empty?)
      end

      def test_value
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string' }
        )
        array = Array.new(%w[foo bar], schema, definitions)
        assert_equal(%w[foo bar], array.value)
      end

      def test_items_as_reference
        item_schema = definitions.add_schema('Item', type: 'object')
        item_schema.add_property('property', type: 'string')

        array_schema = Model::Schema.new(
          type: 'array',
          items: { schema: 'Item' }
        )
        array = Array.new(
          [
            { 'property' => 'foo' },
            { 'property' => 'bar' }
          ],
          array_schema,
          definitions
        ).value

        assert_equal('foo', array.first.property)
        assert_equal('bar', array.second.property)
      end

      def test_validation
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string', existence: true }
        )
        array = Array.new(%w[foo bar], schema, definitions)
        assert_predicate(array, :valid?)

        array = Array.new(['foo', nil, 'bar'], schema, definitions)
        assert_predicate(array, :invalid?)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end
    end
  end
end
