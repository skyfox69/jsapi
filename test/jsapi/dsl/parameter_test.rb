# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_example
        parameter = Meta::Parameter.new('param')
        Parameter.new(parameter) { example 'foo' }
        assert_equal('foo', parameter.example('default').value)
      end
    end
  end
end
