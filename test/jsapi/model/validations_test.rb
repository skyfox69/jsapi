# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ValidationsTest < Minitest::Test
      def test_validates_self_against_schema
        schema = Meta::Schema.new(type: 'object', existence: true)
        schema.add_property('foo', type: 'string')

        model = Base.new(DOM.wrap({ 'foo' => 'bar' }, schema))
        assert_predicate(model, :valid?)

        model = Base.new(DOM.wrap({}, schema))
        assert_predicate(model, :invalid?)
        assert_equal(["can't be blank"], model.errors.full_messages)
      end

      def test_validates_attributes_against_property_schemas
        schema = Meta::Schema.new(type: 'object')
        schema.add_property('foo', type: 'string', existence: true)

        model = Base.new(DOM.wrap({ 'foo' => 'bar' }, schema))
        assert_predicate(model, :valid?)

        model = Base.new(DOM.wrap({ 'foo' => '' }, schema))
        assert_predicate(model, :invalid?)
        assert_equal(["foo can't be blank"], model.errors.full_messages)
      end

      def test_validates_nested_attributes_against_nested_property_schemas
        schema = Meta::Schema.new(type: 'object')
        property = schema.add_property('foo', type: 'object')
        property.schema.add_property('bar', type: 'string', existence: true)

        model = Base.new(DOM.wrap({ 'foo' => { 'bar' => 'Foo Bar' } }, schema))
        assert_predicate(model, :valid?)

        model = Base.new(DOM.wrap({ 'foo' => {} }, schema))
        assert_predicate(model, :invalid?)
        assert_equal(["foo.bar can't be blank"], model.errors.full_messages)
      end
    end
  end
end
