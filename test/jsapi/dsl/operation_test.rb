# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      # Model tests

      def test_model
        foo = Class.new(Model::Base)
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { model foo }
        assert_equal(foo, operation.model)
      end

      def test_model_with_block
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
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
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
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
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          parameter 'foo', type: 'string'
        end
        parameter = operation.parameters['foo']
        assert_predicate(parameter.schema, :string?)
      end

      def test_parameter_with_block
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
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
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { parameter 'foo' }

        reference = operation.parameters['foo']
        assert_equal('foo', reference.parameter)
      end

      def test_raises_exception_on_invalid_parameter_type
        operation = Meta::Operation.new('operation')
        assert_raises Error do
          Operation.new(operation).call { parameter 'foo', type: 'bar' }
        end
      end

      # Request body tests

      def test_request_body
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
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
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          request_body schema: 'Foo'
        end
        request_body = operation.request_body
        assert_equal('Foo', request_body.schema.schema)
      end

      def test_raises_exception_on_invalid_request_body_type
        operation = Meta::Operation.new('operation')
        assert_raises Error do
          Operation.new(operation).call { request_body type: 'foo' }
        end
      end

      # Response tests

      def test_response
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          response do
            property 'foo', type: 'string'
          end
        end
        response = operation.responses['default']
        assert_predicate(response.schema, :object?)
      end

      def test_response_with_status
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
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
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          response schema: 'Foo'
        end
        response = operation.responses['default']
        assert_equal('Foo', response.schema.schema)
      end

      def test_response_reference
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { response 'Foo' }

        reference = operation.response('default')
        assert_equal('Foo', reference.response)
      end

      def test_response_reference_with_status
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { response 200, 'Foo' }

        reference = operation.response(200)
        assert_equal('Foo', reference.response)
      end

      def test_raises_exception_on_invalid_response_type
        operation = Meta::Operation.new('operation')
        assert_raises Error do
          Operation.new(operation).call { response type: 'foo' }
        end
      end

      def test_raises_exception_on_invalid_response_arguments
        message = 'name cannot be specified together with keywords ' \
                  'or a block (at response 200)'

        operation = Meta::Operation.new('operation')
        error = assert_raises Error do
          Operation.new(operation).call do
            response 200, 'Foo', type: 'object'
          end
        end
        assert_equal(message, error.message)

        error = assert_raises Error do
          Operation.new(operation).call do
            response 200, 'Foo' do
              property 'foo', type: 'string'
            end
          end
        end
        assert_equal(message, error.message)
      end
    end
  end
end
