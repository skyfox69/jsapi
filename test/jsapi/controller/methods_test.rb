# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class MethodsTest < Minitest::Test
      include DSL
      include Methods

      api_definitions do
        rescue_from RuntimeError, with: 500

        operation 'operation' do
          parameter :foo, type: 'string', existence: true
          response 200, type: 'string'
          response 400, type: 'string'
          response 500, type: 'string'
        end
      end

      attr_accessor :params

      def setup
        self.params = ActionController::Parameters.new
      end

      # api_operation tests

      def test_api_operation
        params['foo'] = 'bar'
        api_operation(:operation, status: 200, &:foo)

        assert_equal(200, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_without_block
        api_operation(:operation, status: 200)
        assert_equal([200], @head_arguments)
      end

      def test_api_operation_renders_an_error_response
        api_operation :operation, status: 200 do
          raise 'bar'
        end
        assert_equal(500, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_raises_an_error_on_undefined_name
        error = assert_raises ArgumentError do
          api_operation(:foo) {}
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_operation_raises_an_error_on_undefined_status_code
        error = assert_raises ArgumentError do
          api_operation(:operation, status: 204) {}
        end
        assert_equal("status code not defined: '204'", error.message)
      end

      def test_api_operation_bang_method_raises_an_error_on_invalid_parameters
        assert_raises ParametersInvalid do
          api_operation!(:operation, status: 200) {}
        end
      end

      # api_parameters tests

      def test_api_parameters
        params['foo'] = 'bar'
        assert_equal('bar', api_params(:operation).foo)
      end

      def test_api_parameters_raises_an_error_on_undefined_operation_name
        error = assert_raises ArgumentError do
          api_params(:foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      # api_response tests

      def test_api_response
        response = api_response('foo', :operation, status: 200)
        assert_equal('"foo"', response.to_json)
      end

      def test_api_response_raises_an_error_on_undefined_operation_name
        error = assert_raises ArgumentError do
          api_response('bar', :foo)
        end
        assert_equal("operation not defined: 'foo'", error.message)
      end

      def test_api_response_raises_an_error_on_undefined_status_code
        error = assert_raises ArgumentError do
          api_response('foo', :operation, status: 204)
        end
        assert_equal("status code not defined: '204'", error.message)
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
