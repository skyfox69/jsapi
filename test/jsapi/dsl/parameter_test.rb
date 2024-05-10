# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_example
        parameter = Meta::Parameter.new('parameter')
        Parameter.new(parameter) { example 'foo' }
        assert_equal('foo', parameter.examples['default'].value)
      end
    end
  end
end
