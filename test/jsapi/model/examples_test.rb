# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ExampleTest < Minitest::Test
      include Examples

      def test_add_example_on_value
        add_example('foo')
        assert_equal('foo', examples['default'].value)
      end

      def test_add_example_on_name_and_options
        add_example('foo', value: 'bar')
        assert_equal('bar', examples['foo'].value)
      end

      def test_add_example_raises_an_error_on_double_example
        add_example('foo', value: 'Foo')
        error = assert_raises { add_example('foo', value: 'Bar') }
        assert_equal('Example already defined: foo', error.message)
      end

      def test_openapi_examples
        add_example(
          'foo',
          summary: 'Summary of foo',
          description: 'Description of foo',
          value: 'Foo'
        )
        add_example(
          'bar',
          summary: 'Summary of bar',
          description: 'Description of bar',
          value: 'Bar'
        )
        assert_equal(
          {
            'foo' => {
              summary: 'Summary of foo',
              description: 'Description of foo',
              value: 'Foo'
            },
            'bar' => {
              summary: 'Summary of bar',
              description: 'Description of bar',
              value: 'Bar'
            }
          },
          openapi_examples
        )
      end
    end
  end
end
