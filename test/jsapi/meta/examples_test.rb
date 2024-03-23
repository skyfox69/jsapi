# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ExampleTest < Minitest::Test
      include Examples

      def test_add_example
        add_example('foo', value: 'bar')
        assert_equal('bar', examples['foo'].value)

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
