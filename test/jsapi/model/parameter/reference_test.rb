# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Parameter
      class ReferenceTest < Minitest::Test
        def test_resolve
          api_definitions = Definitions.new
          parameter = api_definitions.add_parameter('foo')

          parameter_ref = Reference.new('foo')
          assert_equal(parameter, parameter_ref.resolve(api_definitions))
        end

        def test_openapi_parameters
          reference = Reference.new(:my_parameter)
          assert_equal(
            [{ '$ref': '#/components/parameters/my_parameter' }],
            reference.to_openapi_parameters
          )
        end
      end
    end
  end
end
