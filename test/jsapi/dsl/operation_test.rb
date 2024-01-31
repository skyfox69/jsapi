# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      def test_annotations
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          summary 'My summary'
          description 'My description'
          deprecated true
        end

        assert_equal(
          {
            operationId: 'my_operation',
            summary: 'My summary',
            description: 'My description',
            deprecated: true
          },
          operation_model.to_openapi_operation.except(:parameters, :responses)
        )
      end

      # Parameter tests

      def test_parameter
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          parameter 'my_parameter', type: 'string'
        end

        assert_equal(
          [
            {
              name: 'my_parameter',
              required: false,
              deprecated: false,
              schema: {
                type: 'string'
              }
            }
          ],
          operation_model.to_openapi_operation[:parameters]
        )
      end

      def test_parameter_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          parameter 'my_parameter', '$ref': 'my_reusable_parameter'
        end

        assert_equal(
          [{ '$ref': '#/components/parameters/my_reusable_parameter' }],
          operation_model.to_openapi_operation[:parameters]
        )
      end

      def test_invalid_parameter_type
        operation_model = Model::Operation.new('my_operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { parameter 'my_parameter', type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at 'my_parameter')", error.message)
      end

      # Request body tests

      def test_request_body
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          request_body type: 'object' do
            property 'my_property', type: 'string', required: true
          end
        end

        assert_equal(
          {
            content: {
              'application/json' => {
                schema: {
                  type: 'object',
                  properties: {
                    'my_property' => {
                      type: 'string'
                    }
                  },
                  required: %w[my_property]
                }
              }
            },
            required: false
          },
          operation_model.to_openapi_operation[:request_body]
        )
      end

      def test_request_body_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          request_body '$ref': 'my_request_body'
        end

        assert_equal(
          {
            content: {
              'application/json' => {
                schema: { '$ref': '#/components/schemas/my_request_body' }
              }
            },
            required: false
          },
          operation_model.to_openapi_operation[:request_body]
        )
      end

      def test_invalid_request_body_type
        operation_model = Model::Operation.new('my_operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { request_body type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at request body)", error.message)
      end

      # Response tests

      def test_response
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          response 200, type: 'object' do
            property 'my_property', type: 'string'
          end
        end

        assert_equal(
          {
            200 => {
              content: {
                'application/json' => {
                  schema: {
                    type: 'object',
                    properties: {
                      'my_property' => {
                        type: 'string'
                      }
                    },
                    required: []
                  }
                }
              }
            }
          },
          operation_model.to_openapi_operation[:responses]
        )
      end

      def test_default_response
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          response type: 'object' do
            property 'my_property', type: 'string'
          end
        end

        assert_equal(
          {
            'default' => {
              content: {
                'application/json' => {
                  schema: {
                    type: 'object',
                    properties: {
                      'my_property' => {
                        type: 'string'
                      }
                    },
                    required: []
                  }
                }
              }
            }
          },
          operation_model.to_openapi_operation[:responses]
        )
      end

      def test_response_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          response '$ref': 'my_response'
        end

        assert_equal(
          {
            'default' => {
              content: {
                'application/json' => {
                  schema: { '$ref': '#/components/schemas/my_response' }
                }
              }
            }
          },
          operation_model.to_openapi_operation[:responses]
        )
      end

      def test_invalid_response_type
        operation_model = Model::Operation.new('my_operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { response type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at response)", error.message)
      end
    end
  end
end
