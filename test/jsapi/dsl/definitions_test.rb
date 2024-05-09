# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      def test_include
        foo_class = Class.new do
          extend ClassMethods
          api_definitions do
            schema 'Foo'
          end
        end
        bar_class = Class.new do
          extend ClassMethods
          api_definitions do
            include foo_class
          end
        end
        definitions = bar_class.api_definitions
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      def test_openapi
        Definitions.new(definitions).call do
          openapi(info: { title: 'Foo', version: '1' })
        end
        assert_equal(
          {
            swagger: '2.0',
            info: {
              title: 'Foo',
              version: '1'
            }
          },
          definitions.openapi_document('2.0')
        )
      end

      def test_openapi_with_block
        Definitions.new(definitions).call do
          openapi { info title: 'Foo', version: '1' }
        end
        assert_equal(
          {
            swagger: '2.0',
            info: {
              title: 'Foo',
              version: '1'
            }
          },
          definitions.openapi_document('2.0')
        )
      end

      def test_operation_with_name
        Definitions.new(definitions).call { operation 'foo' }
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_operation_without_name
        definitions = Meta::Definitions.new('Foo')
        Definitions.new(definitions).call { operation }
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_parameter
        Definitions.new(definitions).call do
          parameter 'foo', type: 'string'
        end
        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('string', parameter.type)
      end

      def test_parameter_with_block
        Definitions.new(definitions).call do
          parameter 'foo' do
            description 'Description of foo'
          end
        end
        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('Description of foo', parameter.description)
      end

      def test_request_body
        Definitions.new(definitions).call do
          request_body 'foo', type: 'string'
        end
        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('string', request_body.type)
      end

      def test_request_body_with_block
        Definitions.new(definitions).call do
          request_body 'foo' do
            description 'Description of foo'
          end
        end
        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('Description of foo', request_body.description)
      end

      def test_recue_from
        Definitions.new(definitions).call do
          rescue_from StandardError, with: 500
        end
        rescue_handlers = definitions.rescue_handlers
        assert_equal([500], rescue_handlers.map(&:status))
      end

      def test_response
        Definitions.new(definitions).call { response 'foo' }
        assert_predicate(definitions.response('foo'), :present?)
      end

      def test_response_with_block
        Definitions.new(definitions).call do
          response 'foo' do
            description 'Description of foo'
          end
        end
        response = definitions.response('foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      def test_schema
        Definitions.new(definitions).call { schema 'foo' }
        assert_predicate(definitions.schema('foo'), :present?)
      end

      def test_schema_with_block
        Definitions.new(definitions).call do
          schema 'foo' do
            description 'Description of foo'
          end
        end
        schema = definitions.schema('foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      private

      def definitions
        @definitions ||= Meta::Definitions.new
      end
    end
  end
end
