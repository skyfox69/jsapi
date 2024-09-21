# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      def test_default
        definitions = self.definitions do
          default 'array', within_requests: []
        end
        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.within_requests)
      end

      def test_default_with_block
        definitions = self.definitions do
          default 'array' do
            within_requests []
          end
        end
        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.within_requests)
      end

      def test_include
        struct = Struct.new(:api_definitions)
        owner1 = struct.new(definitions { schema 'Foo' })
        owner2 = struct.new(definitions { include owner1 })

        schema = owner2.api_definitions.find_schema('Foo')
        assert_predicate(schema, :present?)
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

      def test_named_operation
        definitions = self.definitions do
          operation 'foo'
        end
        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
      end

      def test_nameless_operation
        definitions = definitions(owner: 'Foo') do
          operation
        end
        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
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

      def definitions(keywords = {}, &block)
        Meta::Definitions.new(keywords).tap do |definitions|
          Definitions.new(definitions, &block)
        end
      end
    end
  end
end
