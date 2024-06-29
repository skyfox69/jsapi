# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module JSON
    class ObjectTest < Minitest::Test
      def test_model
        schema = Meta::Schema.new(type: 'object')
        object = Object.new({}, schema, definitions)
        assert_kind_of(Model::Base, object.model)
      end

      def test_empty_predicate
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        assert_predicate(Object.new({}, schema, definitions), :empty?)
        assert(!Object.new({ 'foo' => 'bar' }, schema, definitions).empty?)
      end

      # Attributes tests

      def test_bracket_operator
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'bar' }, schema, definitions)
        assert_equal('bar', object[:foo])

        object = Object.new({}, schema, definitions)
        assert_nil(object[nil])
      end

      def test_attribute_predicate
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({}, schema, definitions)
        assert(object.attribute?(:foo))
        assert(!object.attribute?(:bar))
        assert(!object.attribute?(nil))
      end

      def test_attributes
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'bar' }, schema, definitions)
        assert_equal({ 'foo' => 'bar' }, object.attributes)
      end

      def test_attributes_on_polymorphism
        definitions
          .add_schema('base', discriminator: { property_name: 'type' })
          .add_property('type', type: 'string')

        definitions
          .add_schema('foo', all_of: [{ ref: 'base' }])
          .add_property('foo', type: 'string')

        object = Object.new(
          { 'type' => 'foo', 'foo' => 'bar' },
          definitions.schema('base'),
          definitions
        )
        assert_equal(
          { 'type' => 'foo', 'foo' => 'bar' },
          object.attributes
        )
      end

      # Validation tests

      def test_validates_self_against_schema
        schema = Meta::Schema.new(type: 'object', existence: true)
        schema.add_property('foo', type: 'string')

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        errors = Model::Errors.new
        assert(object.validate(errors))
        assert_predicate(errors, :empty?)

        object = Object.new({}, schema, definitions)
        errors = Model::Errors.new
        assert(!object.validate(errors))
        assert(errors.added?(:base, "can't be blank"))
      end

      def test_validates_attributes_against_property_schema
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string', existence: true)

        object = Object.new({ 'foo' => 'foo' }, schema, definitions)
        errors = Model::Errors.new
        assert(object.validate(errors))
        assert_predicate(errors, :empty?)

        object = Object.new({ 'foo' => '' }, schema, definitions)
        errors = Model::Errors.new
        assert(!object.validate(errors))
        assert(errors.added?(:foo, "can't be blank"))
      end

      def test_validates_nested_attributes_against_model
        schema = Meta::Schema.new(type: 'object')
        property = schema.add_property('foo', type: 'object')
        property.schema.add_property('bar', type: 'string', existence: true)

        object = Object.new({ 'foo' => { 'bar' => 'Bar' } }, schema, definitions)
        errors = Model::Errors.new
        assert(object.validate(errors))
        assert_predicate(errors, :empty?)

        object = Object.new({ 'foo' => { 'bar' => nil } }, schema, definitions)
        errors = Model::Errors.new
        assert(!object.validate(errors))
        assert(errors.added?(:foo, "'bar' can't be blank"))
      end

      # Reference test

      def test_property_as_reference
        definitions.add_schema('Foo', type: 'string')

        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', schema: 'Foo')

        object = Object.new({ 'foo' => 'bar' }, schema, definitions)
        assert_equal('bar', object['foo'])
      end

      # inspect

      def test_inspect
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        assert_equal(
          '#<Jsapi::JSON::Object foo: #<Jsapi::JSON::String "bar">>',
          Object.new({ 'foo' => 'bar' }, schema, definitions).inspect
        )
      end

      private

      def definitions
        @definitions ||= Meta::Definitions.new
      end
    end
  end
end
