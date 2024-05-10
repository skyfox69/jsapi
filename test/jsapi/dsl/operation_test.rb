# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      def test_method
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { method 'post' }
        assert_equal('post', operation.method)
      end

      # Callback tests

      def test_callback
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          callback 'foo' do
            operation '{$request.query.foo}', 'bar'
          end
        end
        assert_equal(
          { '{$request.query.foo}' => 'bar' },
          operation.callback('foo').operations.transform_values(&:name)
        )
      end

      def test_callback_reference
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { callback ref: 'foo' }
        assert_equal('foo', operation.callback('foo').ref)
      end

      def test_callback_reference_by_name
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { callback 'foo' }
        assert_equal('foo', operation.callback('foo').ref)
      end

      def test_callback_raises_an_exception_on_ambiguous_keywords
        operation = Meta::Operation.new('foo')
        error = assert_raises(Error) do
          Operation.new(operation) do
            callback 'foo', ref: 'bar' do
              operation '{$request.query.foo}', 'bar'
            end
          end
        end
        assert_equal(
          'unsupported method: operation (at callback "foo")',
          error.message
        )
      end

      # Model tests

      def test_model
        foo = Class.new(Model::Base)
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { model foo }
        assert_equal(foo, operation.model)
      end

      def test_model_with_block
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          model do
            def foo
              'bar'
            end
          end
        end
        bar = operation.model.new({})
        assert_kind_of(Model::Base, bar)
        assert_equal('bar', bar.foo)
      end

      def test_model_with_class_and_block
        foo = Class.new(Model::Base)
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          model foo do
            def foo
              'bar'
            end
          end
        end
        bar = operation.model.new({})
        assert_kind_of(foo, bar)
        assert_equal('bar', bar.foo)
      end

      # Parameter tests

      def test_parameter
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          parameter 'foo', type: 'string'
        end
        parameter = operation.parameters['foo']
        assert_predicate(parameter.schema, :string?)
      end

      def test_parameter_with_block
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          parameter 'foo', type: 'object' do
            property 'bar', type: 'string'
          end
        end
        parameter = operation.parameters['foo']
        assert_predicate(parameter.schema, :object?)

        property = parameter.schema.properties['bar']
        assert_predicate(property.schema, :string?)
      end

      def test_parameter_reference
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { parameter ref: 'foo' }
        assert_equal('foo', operation.parameters['foo'].ref)
      end

      def test_parameter_reference_by_name
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { parameter 'foo' }
        assert_equal('foo', operation.parameters['foo'].ref)
      end

      def test_parameter_raises_an_exception_on_invalid_type
        operation = Meta::Operation.new('foo')
        assert_raises(Error) do
          Operation.new(operation) { parameter 'foo', type: 'bar' }
        end
      end

      def test_parameter_raises_an_exception_on_ambiguous_keywords
        operation = Meta::Operation.new('foo')
        error = assert_raises(Error) do
          Operation.new(operation) do
            parameter 'foo', ref: 'bar', type: 'string'
          end
        end
        assert_equal(
          'unsupported keyword: type (at parameter "foo")',
          error.message
        )
      end

      # Request body tests

      def test_request_body
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          request_body type: 'object' do
            property 'foo', type: 'string'
          end
        end
        request_body = operation.request_body
        assert_predicate(request_body.schema, :object?)

        property = request_body.schema.properties['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_request_body_reference
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          request_body schema: 'Foo'
        end
        request_body = operation.request_body
        assert_equal('Foo', request_body.schema.schema)
      end

      def test_request_body_raises_an_exception_on_invalid_type
        operation = Meta::Operation.new('foo')
        assert_raises(Error) do
          Operation.new(operation) { request_body type: 'foo' }
        end
      end

      # Response tests

      def test_response
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          response do
            property 'foo', type: 'string'
          end
        end
        response = operation.responses['default']
        assert_predicate(response.schema, :object?)
      end

      def test_response_with_status
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          response 200 do
            property 'foo', type: 'string'
          end
        end
        response = operation.response(200)
        assert_predicate(response.schema, :object?)

        property = response.schema.properties['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_response_with_schema_reference
        operation = Meta::Operation.new('foo')
        Operation.new(operation) do
          response schema: 'foo'
        end
        response = operation.responses['default']
        assert_equal('foo', response.schema.schema)
      end

      def test_response_reference
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { response 'foo' }
        assert_equal('foo', operation.response('default').ref)
      end

      def test_response_reference_with_status
        operation = Meta::Operation.new('foo')
        Operation.new(operation) { response 200, 'foo' }
        assert_equal('foo', operation.response(200).ref)
      end

      def test_response_raises_an_exception_on_invalid_type
        operation = Meta::Operation.new('foo')
        assert_raises(Error) do
          Operation.new(operation) { response type: 'foo' }
        end
      end

      def test_response_raises_an_exception_on_invalid_arguments
        message = 'name cannot be specified together with keywords ' \
                  'or a block (at response 200)'

        operation = Meta::Operation.new('foo')
        error = assert_raises(Error) do
          Operation.new(operation) do
            response 200, 'foo', type: 'object'
          end
        end
        assert_equal(message, error.message)

        error = assert_raises(Error) do
          Operation.new(operation) do
            response 200, 'foo' do
              property 'bar', type: 'string'
            end
          end
        end
        assert_equal(message, error.message)
      end
    end
  end
end
