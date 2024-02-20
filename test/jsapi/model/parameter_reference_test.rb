# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ParameterReferenceTest < Minitest::Test
      def test_resolve
        api_definitions = Definitions.new
        parameter = api_definitions.add_parameter('foo')

        parameter_ref = ParameterReference.new('foo')
        assert_equal(parameter, parameter_ref.resolve(api_definitions))
      end

      def test_openapi_parameters_2_0
        reference = ParameterReference.new(:foo)
        assert_equal(
          [{ '$ref': '#/parameters/foo' }],
          reference.to_openapi_parameters('2.0')
        )
      end

      def test_openapi_parameters_3_0
        reference = ParameterReference.new(:foo)
        assert_equal(
          [{ '$ref': '#/components/parameters/foo' }],
          reference.to_openapi_parameters('3.0.3')
        )
      end
    end
  end
end
