# frozen_string_literal: true

module Jsapi
  module DSL
    class OperationTest < Minitest::Test
      def test_summary
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call { summary 'My summary' }
        assert_equal('My summary', operation_model.summary)
      end

      def test_description
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call { description 'My description' }
        assert_equal('My description', operation_model.description)
      end

      def test_deprecated
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call { deprecated true }
        assert(operation_model.deprecated?)
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
              in: 'query',
              schema: {
                type: 'string',
                nullable: true
              }
            }
          ],
          operation_model.to_openapi_operation('3.0.3', definitions)[:parameters]
        )
      end

      def test_parameters_with_block
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          parameter 'my_parameter', type: 'object' do
            property 'my_property', type: 'string'
          end
        end

        assert_equal(
          [
            {
              name: 'my_parameter[my_property]',
              in: 'query',
              schema: {
                type: 'string',
                nullable: true
              }
            }
          ],
          operation_model.to_openapi_operation('3.0.3', definitions)[:parameters]
        )
      end

      def test_parameter_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call { parameter 'my_parameter' }

        assert_equal(
          [
            { '$ref': '#/components/parameters/my_parameter' }
          ],
          operation_model.to_openapi_operation('3.0.3', definitions)[:parameters]
        )
      end

      def test_raises_error_on_invalid_parameter_type
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
            property 'my_property', type: 'string', existence: true
          end
        end

        assert_equal(
          {
            content: {
              'application/json' => {
                schema: {
                  type: 'object',
                  nullable: true,
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
          operation_model.to_openapi_operation('3.0.3', definitions)[:request_body]
        )
      end

      def test_request_body_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          request_body schema: 'my_request_body'
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
          operation_model.to_openapi_operation('3.0.3', definitions)[:request_body]
        )
      end

      def test_raises_error_on_invalid_request_body_type
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
                    nullable: true,
                    properties: {
                      'my_property' => {
                        type: 'string',
                        nullable: true
                      }
                    },
                    required: []
                  }
                }
              }
            }
          },
          operation_model.to_openapi_operation('3.0.3', definitions)[:responses]
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
                    nullable: true,
                    properties: {
                      'my_property' => {
                        type: 'string',
                        nullable: true
                      }
                    },
                    required: []
                  }
                }
              }
            }
          },
          operation_model.to_openapi_operation('3.0.3', definitions)[:responses]
        )
      end

      def test_response_reference
        operation_model = Model::Operation.new('my_operation')
        Operation.new(operation_model).call do
          response schema: 'my_response'
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
          operation_model.to_openapi_operation('3.0.3', definitions)[:responses]
        )
      end

      def test_raises_error_on_invalid_response_type
        operation_model = Model::Operation.new('my_operation')

        error = assert_raises Error do
          Operation.new(operation_model).call { response type: 'foo' }
        end
        assert_equal("invalid type: 'foo' (at response)", error.message)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end
    end
  end
end
