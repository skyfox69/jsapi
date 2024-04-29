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
        Definitions.new(definitions).call { parameter 'foo', type: 'string' }
        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('string', parameter.schema.type)
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

      def test_recue_from
        Definitions.new(definitions).call do
          rescue_from StandardError, with: 500
        end
        rescue_handlers = definitions.rescue_handlers
        assert_equal([500], rescue_handlers.map(&:status))
      end

      def test_response
        Definitions.new(definitions).call { response 'Foo' }
        assert_predicate(definitions.response('Foo'), :present?)
      end

      def test_response_with_block
        Definitions.new(definitions).call do
          response 'Foo' do
            description 'Description of foo'
          end
        end
        response = definitions.response('Foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      def test_schema
        Definitions.new(definitions).call { schema 'Foo' }
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      def test_schema_with_block
        Definitions.new(definitions).call do
          schema 'Foo' do
            description 'Description of foo'
          end
        end
        schema = definitions.schema('Foo')
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
