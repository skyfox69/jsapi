# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      def test_summary
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call { summary 'Foo' }
        assert_equal('Foo', operation_model.summary)
      end

      def test_description
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call { description 'Foo' }
        assert_equal('Foo', operation_model.description)
      end

      def test_deprecated
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call { deprecated true }
        assert(operation_model.deprecated?)
      end

      # Parameter tests

      def test_parameter
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          parameter 'foo', type: 'string'
        end
        parameter = operation_model.parameters['foo']
        assert_predicate(parameter.schema, :string?)
      end

      def test_parameter_with_block
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          parameter 'foo', type: 'object' do
            property 'bar', type: 'string'
          end
        end
        parameter = operation_model.parameters['foo']
        assert_predicate(parameter.schema, :object?)

        property = parameter.schema.properties(definitions)['bar']
        assert_predicate(property.schema, :string?)
      end

      def test_parameter_reference
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call { parameter 'foo' }

        parameter = operation_model.parameters['foo']
        assert_equal('foo', parameter.reference)
      end

      def test_raises_error_on_invalid_parameter_type
        operation_model = Model::Operation.new('operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { parameter 'foo', type: 'bar' }
        end
        assert_equal("invalid type: 'bar' (at 'foo')", error.message)
      end

      # Request body tests

      def test_request_body
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          request_body type: 'object' do
            property 'foo', type: 'string'
          end
        end
        request_body = operation_model.request_body
        assert_predicate(request_body.schema, :object?)

        property = request_body.schema.properties(definitions)['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_request_body_reference
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          request_body schema: 'Foo'
        end
        request_body = operation_model.request_body
        assert_equal('Foo', request_body.schema.reference)
      end

      def test_raises_error_on_invalid_request_body_type
        operation_model = Model::Operation.new('operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { request_body type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at request body)", error.message)
      end

      # Response tests

      def test_response
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          response 200, type: 'object' do
            property 'foo', type: 'string'
          end
        end
        response = operation_model.responses[200]
        assert_predicate(response.schema, :object?)

        property = response.schema.properties(definitions)['foo']
        assert_predicate(property.schema, :string?)
      end

      def test_default_response
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          response type: 'object' do
            property 'foo', type: 'string'
          end
        end
        response = operation_model.responses['default']
        assert_predicate(response.schema, :object?)
      end

      def test_response_reference
        operation_model = Model::Operation.new('operation')
        Operation.new(operation_model).call do
          response schema: 'Foo'
        end
        response = operation_model.responses['default']
        assert_equal('Foo', response.schema.reference)
      end

      def test_raises_error_on_invalid_response_type
        operation_model = Model::Operation.new('operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { response type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at response)", error.message)
      end

      private

      def definitions
        Model::Definitions.new
      end
    end
  end
end
