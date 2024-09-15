# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class AttributesTest < Minitest::Test
      def test_bracket_operator
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({ 'foo' => 'bar' }, schema))
        assert_equal('bar', model['foo'])
        assert_equal('bar', model[:foo])
      end

      def test_attribute_predicate
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({}, schema))

        assert(model.attribute?('foo'))
        assert(model.attribute?(:foo))

        assert(!model.attribute?('bar'))
        assert(!model.attribute?(:bar))
      end

      def test_attributes
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({}, schema))
        assert_equal({ 'foo' => nil }, model.attributes)

        model = Base.new(JSON.wrap({ 'foo' => 'bar' }, schema))
        assert_equal({ 'foo' => 'bar' }, model.attributes)

        model.additional_attributes
      end

      def test_additional_attributes
        schema = Meta::Schema.new(
          type: 'object',
          additional_properties: { type: 'string' }
        )
        model = Base.new(JSON.wrap({}, schema))
        assert_equal({}, model.additional_attributes)

        model = Base.new(JSON.wrap({ 'foo' => 'bar' }, schema))
        assert_equal({ 'foo' => 'bar' }, model.additional_attributes)
      end

      def test_attribute_reader
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({ 'foo' => 'bar' }, schema))
        assert_equal('bar', model.foo)
      end

      def test_attribute_reader_on_camel_case
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('fooBar', type: 'string')

        model = Base.new(JSON.wrap({ 'fooBar' => 'bar' }, schema))
        assert_equal('bar', model.foo_bar)
      end

      def test_respond_to
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({}, schema))

        assert(model.respond_to?(:foo))
        assert(!model.respond_to?(:bar))
      end

      def test_raises_an_exception_on_missing_attribute
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string')

        model = Base.new(JSON.wrap({}, schema))
        assert_raises(NoMethodError) { model.bar }
      end
    end
  end
end
