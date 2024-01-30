# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ParameterTest < Minitest::Test
      def test_new
        parameter = Parameter.new('my_parameter', type: 'string')
        assert_equal('my_parameter', parameter.name)
        assert_equal('string', parameter.schema.type)
      end

      def test_new_reference
        parameter = Parameter.new('my_parameter', '$ref': :my_parameter)
        assert_equal(:my_parameter, parameter.reference)
      end
    end
  end
end
