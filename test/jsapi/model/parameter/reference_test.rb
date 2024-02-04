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

        def test_resolve_recursively
          api_definitions = Definitions.new
          parameter = api_definitions.add_parameter('foo')

          api_definitions.add_parameter('foo_ref', '$ref': 'foo')

          parameter_ref = Reference.new('foo_ref')
          assert_equal(parameter, parameter_ref.resolve(api_definitions))
        end

        def test_openapi_parameters
          reference = Reference.new(:foo)
          assert_equal(
            [{ '$ref': '#/components/parameters/foo' }],
            reference.to_openapi_parameters
          )
        end
      end
    end
  end
end
