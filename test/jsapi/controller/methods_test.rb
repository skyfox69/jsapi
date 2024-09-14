# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class MethodsTest < Minitest::Test
      # api_operation and api_operation!

      %i[api_operation api_operation!].each do |method|
        name = method.to_s.gsub('!', 'bang')

        define_method("test_#{name}") do
          controller = dummy_controller do
            api_operation do
              response 200, type: 'string', content_type: 'application/foo'
            end
          end
          # Method call without block
          controller.send(method, status: 200)
          response = controller.response

          assert_equal(200, response.status)
          assert_equal('application/foo', response.content_type)
          assert_nil(response.body)

          # Method call with block
          controller.send(method, status: 200) { 'foo' }
          response = controller.response

          assert_equal(200, response.status)
          assert_equal('application/foo', response.content_type)
          assert_equal('"foo"', response.body)

          # Errors
          error = assert_raises RuntimeError do
            controller.send(method, :foo)
          end
          assert_equal('operation not defined: foo', error.message)

          error = assert_raises RuntimeError do
            controller.send(method, status: 204)
          end
          assert_equal('status code not defined: 204', error.message)

          error = assert_raises RuntimeError do
            controller.send(method, status: 200) { raise 'foo' }
          end
          assert_equal('foo', error.message)
        end

        define_method("test_#{name}_passes_params_to_the_block") do
          controller = dummy_controller do
            api_operation do
              parameter 'foo', type: 'string'
              response 200, type: 'string'
            end
          end
          controller.params['foo'] = 'bar'

          controller.send(method, status: 200) do |api_params|
            assert_equal('bar', api_params.foo)
          end
        end

        define_method("test_#{name}_renders_an_error_response_when_rescuing_an_exception") do
          controller = dummy_controller do
            api_definitions do
              rescue_from RuntimeError, with: 500

              operation do
                response 200, type: 'string'
                response 500, type: 'string', content_type: 'application/problem+json'
              end
            end
          end
          controller.send(method, status: 200) { raise 'foo' }
          response = controller.response

          assert_equal(500, response.status)
          assert_equal('application/problem+json', response.content_type)
          assert_equal('"foo"', response.body)
        end

        define_method("test_#{name}_calls_an_on_rescue_callback_as_a_method") do
          controller = dummy_controller do
            api_definitions do
              rescue_from RuntimeError, with: 500
              on_rescue :notice_error

              operation do
                response 200, type: 'string'
                response 500, type: 'string'
              end
            end

            attr_reader :error

            def notice_error(error)
              @error = error
            end
          end
          controller.api_operation(status: 200) { raise 'foo' }
          error = controller.error

          assert_kind_of(RuntimeError, error)
          assert_equal('foo', error.message)
        end

        define_method("test_#{name}_calls_an_on_rescue_callback_as_a_block") do
          error = nil

          controller = dummy_controller do
            api_definitions do
              rescue_from RuntimeError, with: 500
              on_rescue { |e| error = e }

              operation do
                response 200, type: 'string'
                response 500, type: 'string'
              end
            end
          end
          controller.api_operation(status: 200) { raise 'foo' }

          assert_kind_of(RuntimeError, error)
          assert_equal('foo', error.message)
        end

        define_method("test_#{name}_reraises_an_exception_if_error_response_does_not_exist") do
          controller = dummy_controller do
            api_definitions do
              rescue_from RuntimeError, with: 500

              operation do
                response 200, type: 'string'
              end
            end
          end
          error = assert_raises(RuntimeError) do
            controller.api_operation(status: 200) { raise 'foo' }
          end
          assert_equal('foo', error.message)
        end
      end

      # api_params

      def test_api_params
        controller = dummy_controller do
          api_operation do
            parameter 'foo', type: 'string'
            response 200, type: 'string'
          end
        end
        controller.params['foo'] = 'bar'
        assert_equal('bar', controller.api_params.foo)

        # Errors
        error = assert_raises RuntimeError do
          controller.api_params('foo')
        end
        assert_equal('operation not defined: foo', error.message)
      end

      # api_response

      def test_api_response
        controller = dummy_controller do
          api_operation do
            response 200, type: 'string'
          end
        end
        response = controller.api_response('foo', status: 200)
        assert_equal('"foo"', response.to_json)

        # Errors
        error = assert_raises RuntimeError do
          controller.api_response('foo', 'foo', status: 200)
        end
        assert_equal('operation not defined: foo', error.message)

        error = assert_raises RuntimeError do
          controller.api_response('foo', status: 204)
        end
        assert_equal('status code not defined: 204', error.message)
      end

      # Strong parameters

      def test_strong_parameters
        controller = dummy_controller do
          api_operation do
            parameter 'foo', type: 'string'
            response 200, type: 'string'
          end
        end
        # Allowed parameters only
        controller.params[:foo] = 'bar'
        controller.params[:controller] = 'Foo'
        controller.params[:action] = 'bar'

        # api_params
        assert_predicate(controller.api_params(strong: true), :valid?)

        # api_operation
        controller.api_operation(status: 200, strong: true) do |api_params|
          assert_predicate(api_params, :valid?)
        end
        # api_operation!
        controller.api_operation!(status: 200, strong: true) do |api_params|
          assert_predicate(api_params, :valid?)
        end

        # At least one forbidden parameter
        controller.params[:bar] = 'foo'

        # api_params
        controller.api_params(strong: true).tap do |api_params|
          assert_predicate(api_params, :invalid?)
          assert(api_params.errors.added?(:base, "'bar' isn't allowed"))
        end
        # api_operation
        controller.api_operation(status: 200, strong: true) do |api_params|
          assert_predicate(api_params, :invalid?)
          assert(api_params.errors.added?(:base, "'bar' isn't allowed"))
        end
        # api_operation!
        error = assert_raises Jsapi::Controller::ParametersInvalid do
          controller.api_operation!(status: 200, strong: true) do
            assert(false) # Expected this line to not be reached
          end
        end
        assert_equal("'bar' isn't allowed.", error.message)
      end

      private

      def dummy_controller(&block)
        controller_class = Class.new do
          include DSL
          include Methods

          def content_type=(content_type)
            response.content_type = content_type
          end

          def head(*args)
            response.status = args.first
          end

          def headers
            {}
          end

          def params
            @params ||= ActionController::Parameters.new
          end

          def render(**options)
            response.status = options[:status]
            response.body = options[:json]&.to_json
          end

          def response
            @response ||= ActionDispatch::Response.new
          end
        end
        controller_class.class_eval(&block)
        controller_class.new
      end
    end
  end
end
