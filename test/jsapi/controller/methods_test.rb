# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class MethodsTest < Minitest::Test
      include DSL
      include Methods

      # To test that an exception is reraised
      class NotFoundError < StandardError; end

      api_definitions do
        rescue_from NotFoundError, with: 404
        rescue_from RuntimeError, with: 500

        operation do
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
        api_operation(status: 200, &:foo)

        assert_equal(200, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_on_strong
        params['foo'] = 'bar' # allowed
        api_operation(status: 200, strong: true) do |api_params|
          assert_predicate(api_params, :valid?)
        end

        params['bar'] = 'foo' # forbidden
        api_operation(status: 200, strong: true) do |api_params|
          assert_predicate(api_params, :invalid?)
          assert(api_params.errors.added?(:base, "'bar' isn't allowed"))
        end
      end

      def test_api_operation_without_block
        api_operation(status: 200)
        assert_equal([200], @head_arguments)
      end

      def test_api_operation_renders_an_error_response
        api_operation status: 200 do
          raise 'bar'
        end
        assert_equal(500, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_raises_an_exception_on_undefined_name
        error = assert_raises RuntimeError do
          api_operation(:foo) {}
        end
        assert_equal('operation not defined: foo', error.message)
      end

      def test_api_operation_raises_an_exception_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_operation(status: 204) {}
        end
        assert_equal('status code not defined: 204', error.message)
      end

      def test_api_operation_reraises_an_exception
        assert_raises NotFoundError do
          api_operation status: 200 do
            raise NotFoundError
          end
        end
      end

      # api_operation! tests

      def test_api_operation_bang
        params['foo'] = 'bar'
        api_operation!(status: 200, &:foo)

        assert_equal(200, @render_options[:status])
        assert_equal('"bar"', @render_options[:json].to_json)
      end

      def test_api_operation_bang_on_strong
        params['foo'] = 'bar' # allowed
        api_operation!(status: 200, strong: true, &:foo)
        assert_equal(200, @render_options[:status])

        params['bar'] = 'foo' # forbidden
        error = assert_raises ParametersInvalid do
          api_operation!(status: 200, strong: true, &:foo)
        end
        assert_equal("'bar' isn't allowed.", error.message)
      end

      # api_parameters tests

      def test_api_parameters
        params['foo'] = 'bar'
        assert_equal('bar', api_params.foo)
      end

      def test_api_parameters_on_strong_parameters
        params['foo'] = 'bar' # allowed
        assert_predicate(api_params(strong: true), :valid?)

        params['bar'] = 'foo' # forbidden
        api_params = api_params(strong: true)
        assert_predicate(api_params, :invalid?)
        assert(api_params.errors.added?(:base, "'bar' isn't allowed"))
      end

      def test_api_parameters_raises_an_exception_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_params(:foo)
        end
        assert_equal('operation not defined: foo', error.message)
      end

      # api_response tests

      def test_api_response
        response = api_response('foo', status: 200)
        assert_equal('"foo"', response.to_json)
      end

      def test_api_response_raises_an_exception_on_undefined_operation_name
        error = assert_raises RuntimeError do
          api_response('bar', :foo)
        end
        assert_equal('operation not defined: foo', error.message)
      end

      def test_api_response_raises_an_exception_on_undefined_status_code
        error = assert_raises RuntimeError do
          api_response('foo', status: 204)
        end
        assert_equal('status code not defined: 204', error.message)
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
