# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class BaseTest < Minitest::Test
      class MyController < Base
        public :api_definitions

        api_definitions do
          path '/my_path' do
            operation :get, 'my_operation'
          end
        end
      end

      def test_integration
        controller = MyController.new
        api_definitions = controller.api_definitions

        assert_predicate(api_definitions.path('/my_path'), :present?)
      end
    end
  end
end
