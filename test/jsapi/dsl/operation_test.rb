# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      def test_summary
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { summary 'Foo' }
        assert_equal('Foo', operation.summary)
      end

      def test_description
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { description 'Foo' }
        assert_equal('Foo', operation.description)
      end

      def test_deprecated
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { deprecated true }
        assert(operation.deprecated?)
      end

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

        property = parameter.schema.properties(definitions)['bar']
        assert_predicate(property.schema, :string?)
      end

      def test_parameter_reference
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call { parameter 'foo' }

        parameter = operation.parameters['foo']
        assert_equal('foo', parameter.reference)
      end

      def test_raises_error_on_invalid_parameter_type
        operation = Meta::Operation.new('operation')
        error = assert_raises Error do
          Operation.new(operation).call { parameter 'foo', type: 'bar' }
        end
        assert_equal("invalid type: 'bar' (at 'foo')", error.message)
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

        property = request_body.schema.properties(definitions)['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_request_body_reference
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          request_body schema: 'Foo'
        end
        request_body = operation.request_body
        assert_equal('Foo', request_body.schema.reference)
      end

      def test_raises_error_on_invalid_request_body_type
        operation = Meta::Operation.new('operation')

        error = assert_raises Error do
          Operation.new(operation).call { request_body type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at request body)", error.message)
      end

      # Response tests

      def test_response
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          response 200, type: 'object' do
            property 'foo', type: 'string'
          end
        end
        response = operation.responses[200]
        assert_predicate(response.schema, :object?)

        property = response.schema.properties(definitions)['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_default_response
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          response type: 'object' do
            property 'foo', type: 'string'
          end
        end
        response = operation.responses['default']
        assert_predicate(response.schema, :object?)
      end

      def test_response_reference
        operation = Meta::Operation.new('operation')
        Operation.new(operation).call do
          response schema: 'Foo'
        end
        response = operation.responses['default']
        assert_equal('Foo', response.schema.reference)
      end

      def test_raises_error_on_invalid_response_type
        operation = Meta::Operation.new('operation')

        error = assert_raises Error do
          Operation.new(operation).call { response type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at response)", error.message)
      end

      private

      def definitions
        Meta::Definitions.new
      end
    end
  end
end
