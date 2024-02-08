# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ArrayTest < Minitest::Test
      def test_cast
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string' }
        )
        assert_equal(%w[foo bar], Array.new(%w[foo bar], schema).cast)
      end

      def test_validation
        schema = Model::Schema.new(
          type: 'array',
          items: { type: 'string', existence: true }
        )
        assert_predicate(Array.new(%w[foo nbar], schema), :valid?)
        assert_predicate(Array.new(['foo', nil, 'bar'], schema), :invalid?)
      end

      def test_items_as_reference
        definitions = Model::Definitions.new
        item_schema = definitions.add_schema('Item', type: 'object')
        item_schema.add_property('property', type: 'string')

        array_schema = Model::Schema.new(
          type: 'array',
          items: { schema: 'Item' }
        )
        ary = Array.new(
          [
            { 'property' => 'foo' },
            { 'property' => 'bar' }
          ],
          array_schema,
          definitions
        ).cast

        assert_equal('foo', ary.first.property)
        assert_equal('bar', ary.second.property)
      end
    end
  end
end
