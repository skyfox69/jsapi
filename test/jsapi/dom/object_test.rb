# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ObjectTest < Minitest::Test
      def test_value
        schema = Model::Schema.new(type: 'object')
        object = Object.new({}, schema, definitions)
        assert_equal(object, object.value)
      end

      def test_emptiness
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        assert_predicate(Object.new({}, schema, definitions), :empty?)
        assert(!Object.new({ 'foo' => 'bar' }, schema, definitions).empty?)
      end

      # Attribute reader tests

      def test_bracket_operator
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        assert_equal('foo', object[:foo])
      end

      def test_bracket_operator_on_nil
        schema = Model::Schema.new(type: 'object')
        object = Object.new({}, schema, definitions)
        assert_nil(object[nil])
      end

      def test_attributes
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'bar' }, schema, definitions)
        assert_equal({ 'foo' => 'bar' }, object.attributes)
      end

      def test_attribute_reader
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        assert_equal('foo', object.foo)
      end

      def test_raises_error_on_invalid_attribute_name
        schema = Model::Schema.new(type: 'object')
        object = Object.new({}, schema, definitions)
        assert_raises(NoMethodError) { object.foo }
      end

      def test_respond_to
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')
        assert(Object.new({}, schema, definitions).respond_to?(:foo))
      end

      def test_respond_to_on_invalid_attribute_name
        schema = Model::Schema.new(type: 'object')
        assert(!Object.new({}, schema, definitions).respond_to?(:foo))
      end

      # Validation tests

      def test_validates_against_json_schema
        schema = Model::Schema.new(type: 'object', existence: true)
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        assert_predicate(object, :valid?)

        object = Object.new({}, schema, definitions)
        assert_predicate(object, :invalid?)
        assert_equal("Can't be blank", object.errors.full_message)
      end

      def test_validates_attributes
        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string', existence: true)

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        assert_predicate(object, :valid?)

        object = Object.new({ 'foo' => '' }, schema, definitions)
        assert_predicate(object, :invalid?)
        assert_equal("Foo can't be blank", object.errors.full_message)
      end

      def test_validates_nested_attributes
        schema = Model::Schema.new(type: 'object')
        property = schema.add_property('foo', type: 'array', items: { type: 'object' })
        property.schema.items.add_property('bar', type: 'string', existence: true)

        object = Object.new({ 'foo' => [{ 'bar' => 'Bar' }] }, schema, definitions)
        assert_predicate(object, :valid?)

        object = Object.new({ 'foo' => [{ 'bar' => nil }] }, schema, definitions)
        assert_predicate(object, :invalid?)
        assert_equal("Foo bar can't be blank", object.errors.full_message)
      end

      # Reference test

      def test_property_as_reference
        definitions.add_schema('Foo', type: 'string')

        schema = Model::Schema.new(type: 'object')
        schema.add_property('foo', schema: 'Foo')

        object = Object.new({ 'foo' => 'bar' }, schema, definitions)
        assert_equal('bar', object.foo)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end
    end
  end
end
