# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      # #method

      def test_method
        operation = define_operation { method 'post' }
        assert_equal('post', operation.method)
      end

      # #callback

      def test_callback
        operation = define_operation { callback 'onFoo' }
        assert_predicate(operation.callback('onFoo'), :present?)
      end

      # #model

      def test_model
        klass = Class.new(Model::Base)
        operation = define_operation { model klass }
        assert_equal(klass, operation.model)
      end

      def test_model_with_block
        operation = define_operation do
          model do
            def foo
              'bar'
            end
          end
        end
        model = operation.model.new({})
        assert_kind_of(Model::Base, model)
        assert_equal('bar', model.foo)
      end

      def test_model_with_class_and_block
        klass = Class.new(Model::Base)
        operation = define_operation do
          model klass do
            def foo
              'bar'
            end
          end
        end
        model = operation.model.new({})
        assert_kind_of(klass, model)
        assert_equal('bar', model.foo)
      end

      # #parameter

      def test_parameter
        operation = define_operation do
          parameter 'foo', type: 'string'
        end
        parameter = operation.parameter('foo')
        assert_predicate(parameter.schema, :string?)
      end

      def test_parameter_with_block
        operation = define_operation do
          parameter 'foo', type: 'object' do
            property 'bar', type: 'string'
          end
        end
        parameter = operation.parameter('foo')
        assert_predicate(parameter.schema, :object?)

        property = parameter.schema.property('bar')
        assert_predicate(property.schema, :string?)
      end

      def test_parameter_reference
        operation = define_operation do
          parameter ref: 'foo'
        end
        assert_equal('foo', operation.parameter('foo').ref)
      end

      def test_parameter_reference_by_name
        operation = define_operation do
          parameter 'foo'
        end
        assert_equal('foo', operation.parameter('foo').ref)
      end

      def test_parameter_raises_an_exception_on_invalid_type
        error = assert_raises(Error) do
          define_operation { parameter 'foo', type: 'bar' }
        end
        assert(error.message.start_with?('type must be one of'))
      end

      def test_parameter_raises_an_exception_on_ambiguous_keywords
        error = assert_raises(Error) do
          define_operation { parameter 'foo', ref: 'bar', type: 'string' }
        end
        assert_equal('unsupported keyword: type (at parameter "foo")', error.message)
      end

      # #request_body

      def test_request_body
        operation = define_operation do
          request_body type: 'object' do
            property 'foo', type: 'string'
          end
        end
        request_body = operation.request_body
        assert_predicate(request_body.schema, :object?)

        property = request_body.schema.property('foo')
        assert_predicate(property.schema, :string?)
      end

      def test_request_body_on_schema_reference
        operation = define_operation do
          request_body schema: 'foo'
        end
        request_body = operation.request_body
        assert_equal('foo', request_body.schema.ref)
      end

      def test_request_body_reference
        operation = define_operation do
          request_body ref: 'foo'
        end
        assert_equal('foo', operation.request_body.ref)
      end

      def test_request_body_raises_an_exception_on_invalid_type
        error = assert_raises(Error) do
          define_operation { request_body type: 'foo' }
        end
        assert(error.message.start_with?('type must be one of'))
      end

      def test_request_body_raises_an_exception_on_ambiguous_keywords
        error = assert_raises(Error) do
          define_operation { request_body ref: 'foo', type: 'string' }
        end
        assert_equal('unsupported keyword: type (at request body)', error.message)
      end

      # #response

      def test_default_response
        operation = define_operation do
          response do
            property 'foo', type: 'string'
          end
        end
        response = operation.response('default')
        assert_predicate(response.schema, :object?)
      end

      def test_response_with_status
        operation = define_operation do
          response 200 do
            property 'foo', type: 'string'
          end
        end
        response = operation.response(200)
        assert_predicate(response.schema, :object?)
      end

      def test_response_on_schema_reference
        operation = define_operation do
          response schema: 'foo'
        end
        response = operation.responses['default']
        assert_equal('foo', response.schema.ref)
      end

      def test_response_reference
        operation = define_operation do
          response ref: 'foo'
        end
        assert_equal('foo', operation.response('default').ref)
      end

      def test_response_reference_by_name
        operation = define_operation do
          response 'foo'
        end
        assert_equal('foo', operation.response('default').ref)
      end

      def test_response_reference_by_name_with_status
        operation = define_operation do
          response 200, 'foo'
        end
        assert_equal('foo', operation.response(200).ref)
      end

      def test_response_raises_an_exception_on_invalid_type
        error = assert_raises(Error) do
          define_operation { response type: 'foo' }
        end
        assert(error.message.start_with?('type must be one of'))
      end

      def test_response_raises_an_exception_on_invalid_arguments
        message = 'name cannot be specified together with keywords ' \
                  'or a block (at response 200)'

        error = assert_raises(Error) do
          define_operation do
            response 200, 'foo', type: 'object'
          end
        end
        assert_equal(message, error.message)

        error = assert_raises(Error) do
          define_operation do
            response 200, 'foo' do
              property 'bar', type: 'string'
            end
          end
        end
        assert_equal(message, error.message)
      end

      def test_response_raises_an_exception_on_ambiguous_keywords
        error = assert_raises(Error) do
          define_operation { response ref: 'foo', type: 'string' }
        end
        assert_equal('unsupported keyword: type (at response)', error.message)
      end

      private

      def define_operation(**keywords, &block)
        Meta::Operation.new(keywords).tap do |operation|
          Operation.new(operation, &block)
        end
      end
    end
  end
end
