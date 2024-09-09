# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      def test_default
        definitions = self.definitions do
          default 'array', write: []
        end
        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.write)
      end

      def test_default_with_block
        definitions = self.definitions do
          default 'array' do
            write []
          end
        end
        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.write)
      end

      def test_include
        foo_class = Class.new do
          extend ClassMethods
          api_definitions do
            schema 'Foo', description: 'Description of foo'
          end
        end
        bar_class = Class.new do
          extend ClassMethods
          api_definitions do
            include foo_class
          end
        end
        schema = bar_class.api_definitions.schema('Foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      def test_on_rescue
        definitions = self.definitions do
          on_rescue :foo
        end
        assert_equal(:foo, definitions.on_rescue_callbacks.first)
      end

      def test_on_rescue_with_block
        definitions = self.definitions do
          on_rescue { |e| e }
        end
        assert_instance_of(Proc, definitions.on_rescue_callbacks.first)
      end

      def test_openapi
        definitions = self.definitions do
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
        definitions = self.definitions do
          openapi do
            info title: 'Foo', version: '1'
          end
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
        definitions = self.definitions do
          operation 'foo'
        end
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_operation_without_name
        definitions = definitions('Foo') do
          operation
        end
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_parameter
        definitions = self.definitions do
          parameter 'foo', description: 'Description of foo'
        end
        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('Description of foo', parameter.description)
      end

      def test_parameter_with_block
        definitions = self.definitions do
          parameter 'foo' do
            description 'Description of foo'
          end
        end
        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('Description of foo', parameter.description)
      end

      def test_request_body
        definitions = self.definitions do
          request_body 'foo', description: 'Description of foo'
        end
        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('Description of foo', request_body.description)
      end

      def test_request_body_with_block
        definitions = self.definitions do
          request_body 'foo' do
            description 'Description of foo'
          end
        end
        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('Description of foo', request_body.description)
      end

      def test_recue_from
        definitions = self.definitions do
          rescue_from StandardError, with: 500
        end
        rescue_handlers = definitions.rescue_handlers
        assert_equal([500], rescue_handlers.map(&:status))
      end

      def test_response
        definitions = self.definitions do
          response 'foo', description: 'Description of foo'
        end
        response = definitions.response('foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      def test_response_with_block
        definitions = self.definitions do
          response 'foo' do
            description 'Description of foo'
          end
        end
        response = definitions.response('foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      def test_schema
        definitions = self.definitions do
          schema 'foo', description: 'Description of foo'
        end
        schema = definitions.schema('foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      def test_schema_with_block
        definitions = self.definitions do
          schema 'foo' do
            description 'Description of foo'
          end
        end
        schema = definitions.schema('foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      private

      def definitions(owner = nil, &block)
        Meta::Definitions.new(owner).tap do |definitions|
          Definitions.new(definitions, &block)
        end
      end
    end
  end
end
