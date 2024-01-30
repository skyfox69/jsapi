# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class GenericTest < Minitest::Test
      def test_keyword
        generic = Generic.new(foo_bar: '_foo_bar_')
        assert_equal({ fooBar: '_foo_bar_' }, generic.to_openapi)
      end

      def test_keyword_and_child
        generic = Generic.new(foo: '_foo_')
        generic.add_child('bar', nested: '_bar_')

        assert_equal(
          {
            foo: '_foo_',
            bar: {
              nested: '_bar_'
            }
          },
          generic.to_openapi
        )
      end
    end
  end
end
