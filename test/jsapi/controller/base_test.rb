# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class BaseTest < Minitest::Test
      def test_integration
        controller = Class.new(Base) do
          public :api_definitions

          api_definitions do
            operation 'foo'
          end
        end.new
        api_definitions = controller.api_definitions
        assert_predicate(api_definitions.find_operation('foo'), :present?)
      end
    end
  end
end
