# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class MethodsTest < Minitest::Test
      include DSL
      include Methods

      api_operation 'operation' do
        parameter :foo, type: 'string', existence: true
        response type: 'string'
        response 200, type: 'string'
        response 400, type: 'string'
      end

      attr_accessor :params

      def setup
        self.params = ActionController::Parameters.new
      end

      # api_operation tests

      def test_api_operation
        api_operation(:operation, status: 200) { 'bar' }
        assert_equal(200, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_without_block
        api_operation(:operation, status: 204)
        assert_equal([204], @head_arguments)
      end

      def test_api_operation_parameters
        params['foo'] = 'bar'
        api_operation :operation do |api_params|
          assert_equal('bar', api_params.foo)
        end
      end

      def test_api_operation_invalid_parameters
        api_operation :operation, status: { invalid: 400 }
        assert_equal(400, @render_options[:status])
      end

      def test_api_operation_raises_an_error_on_undefined_name
        error = assert_raises RuntimeError do
          api_operation(:foo) {}
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_operation_raises_an_error_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_operation(:operation, status: 204) {}
        end
        assert_equal("status code not defined: '204'", error.message)
      end

      # api_parameters tests

      def test_api_parameters
        params['foo'] = 'my_value'
        assert_equal('my_value', api_params(:operation).foo)
      end

      def test_api_parameters_raises_an_error_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_params(:foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      # api_response tests

      def test_api_response
        response = api_response('My response', :operation)
        assert_equal('"My response"', response.to_json)
      end

      def test_api_response_raises_an_error_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_response('My response', :foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_response_raises_an_error_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_response('My response', :operation, status: 204)
        end
        assert_equal("status code not defined: '204'", error.message)
      end

      # api_status_code tests

      def test_api_status_codes
        status_codes = api_status_codes(200)
        assert_equal(200, status_codes.default)
        assert_nil(status_codes.invalid)

        status_codes = api_status_codes({ default: 200, invalid: 400 })
        assert_equal(200, status_codes.default)
        assert_equal(400, status_codes.invalid)

        status_codes = api_status_codes(status_codes)
        assert_equal(200, status_codes.default)
        assert_equal(400, status_codes.invalid)
      end

      private

      def head(*args)
        @head_arguments = args
      end

      def render(**options)
        @render_options = options
      end
    end
  end
end
