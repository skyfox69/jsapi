# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module OpenAPI
      class ObjectTest < Minitest::Test
        def test_keyword_argument
          dummy_class = Class.new(Object) do
            attr_accessor :foo
          end
          dummy = dummy_class.new(foo: 'bar')
          assert_equal('bar', dummy.foo)
        end

        def test_raises_exception_on_invalid_keyword_argument
          error = assert_raises(ArgumentError) do
            Object.new(foo: 'bar')
          end
          assert_equal('invalid keyword: foo', error.message)
        end
      end
    end
  end
end
