# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class ObjectTest < Minitest::Test
      def test_cast
        object = Object.new({}, schema)

        assert_equal(object, object.cast)
      end

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

      def test_validate_positive
        assert_predicate(Object.new({ 'foo' => 'foo' }, schema), :valid?)
      end

      def test_validate_negative
        assert_predicate(Object.new({ 'foo' => nil }, schema), :invalid?)
      end

      def test_respond_to
        assert(Object.new({}, schema).respond_to?(:foo))
      end

      def test_respond_to_on_invalid_name
        assert(!Object.new({}, schema).respond_to?(:foo_bar))
      end

      private

      def schema
        Model::Schema.new.tap do |schema|
          schema.add_property('foo', type: 'string', nullable: false)
          schema.add_property('bar', type: 'string', nullable: true)
        end
      end
    end
  end
end
