# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class MethodsTest < Minitest::Test
      include DSL
      include Methods

      api_operation 'my_operation' do
        parameter :my_parameter, type: 'string'
        response type: 'string', nullable: true
        response 200, type: 'string'
      end

      attr_accessor :params

      def setup
        self.params = ActionController::Parameters.new
      end

      # #api_operation tests

      def test_api_operation_without_block
        api_operation(:my_operation, status: 204)
        assert_equal([204], @head_args)
      end

      def test_api_operation_parameters
        params['my_parameter'] = 'my_value'

        api_operation :my_operation do |api_params|
          assert_equal('my_value', api_params.my_parameter)
        end
      end

      def test_api_operation_response
        api_operation :my_operation, status: 200 do |_api_params|
          'My response'
        end
        assert_equal(200, @render_options[:status])
        assert_equal('"My response"', @render_options[:json].to_json)
      end

      def test_api_operation_default_response
        api_operation :my_operation do |_api_params|
          'My response'
        end
        assert_nil(@render_options[:status])
      end

      def test_api_operation_on_undefined_name
        error = assert_raises RuntimeError do
          api_operation(:foo) {}
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_operation_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_operation(:my_operation, status: 204) {}
        end
        assert_equal("status code not defined: '204'", error.message)
      end

      # #api_parameters tests

      def test_api_parameters
        params['my_parameter'] = 'my_value'
        assert_equal('my_value', api_params(:my_operation).my_parameter)
      end

      def test_api_parameters_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_params(:foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      # #api_response tests

      def test_api_response
        response = api_response('My response', :my_operation)
        assert_equal('"My response"', response.to_json)
      end

      def test_api_response_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_response('My response', :foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_response_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_response('My response', :my_operation, status: 204)
        end
        assert_equal("status code not defined: '204'", error.message)
      end

      private

      def head(*args)
        @head_args = args
      end

      def render(**options)
        @render_options = options
      end
    end
  end
end
