# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class BaseTest < Minitest::Test
      class MyController < Base
        public :api_definitions

        api_definitions do
          operation 'my_operation'
        end
      end

      def test_integration
        controller = MyController.new
        api_definitions = controller.api_definitions

        assert_predicate(api_definitions.operation('my_operation'), :present?)
      end
    end
  end
end
