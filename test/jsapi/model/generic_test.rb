# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class GenericTest < Minitest::Test
      def test_initialize
        model = Generic.new(foo: 'bar')
        assert_equal('bar', model['foo'])
      end

      def test_bracket_operator
        model = Generic.new
        model['foo'] = 'bar'
        assert_equal('bar', model['foo'])
      end

      def test_add_child
        model = Generic.new
        model.add_child('foo', nested: 'bar')

        assert_equal(
          {
            foo: {
              nested: 'bar'
            }
          },
          model.to_h
        )
      end

      def test_camel_case
        model = Generic.new(foo_bar: 'foo')
        assert_equal({ fooBar: 'foo' }, model.to_h)
      end
    end
  end
end
