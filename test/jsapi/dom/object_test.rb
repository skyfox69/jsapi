# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ObjectTest < Minitest::Test
      def test_empty
        assert_predicate(Object.new({}, schema), :empty?)
        assert(!Object.new({ 'foo' => 'bar' }, schema).empty?)
      end

      def test_cast
        object = Object.new({}, schema)
        assert_equal(object, object.cast)
      end

      # Attribute reader tests

      def test_bracket_operator
        object = Object.new({ 'foo' => 'foo' }, schema)
        assert_equal('foo', object[:foo])
      end

      def test_attributes
        object = Object.new({ 'foo' => 'foo' }, schema)
        assert_equal({ 'foo' => 'foo', 'bar' => nil }, object.attributes)
      end

      def test_attribute_reader
        object = Object.new({ 'foo' => 'foo' }, schema)
        assert_equal('foo', object.foo)
      end

      def test_respond_to
        assert(Object.new({}, schema).respond_to?(:foo))
      end

      def test_respond_to_on_invalid_name
        assert(!Object.new({}, schema).respond_to?(:foo_bar))
      end

      # Validation tests

      def test_validate_positive
        assert_predicate(Object.new({ 'foo' => 'foo', 'bar' => nil }, schema), :valid?)
      end

      def test_validate_negative
        assert_predicate(Object.new({ 'foo' => nil }, schema), :invalid?)
      end

      # Reference test

      def test_property_as_reference
        definitions = Model::Definitions.new
        definitions.add_schema('Property', type: 'string')

        schema = Model::Schema.new(type: 'object')
        schema.add_property('property', schema: 'Property')

        object = Object.new({ 'property' => 'foo' }, schema, definitions)
        assert_equal('foo', object.property)
      end

      private

      def schema
        Model::Schema.new.tap do |schema|
          schema.add_property('foo', type: 'string', existence: true)
          schema.add_property('bar', type: 'string')
        end
      end
    end
  end
end
