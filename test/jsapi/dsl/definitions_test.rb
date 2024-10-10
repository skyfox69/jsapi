# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      # #callback

      def test_callback
        definitions = self.definitions do
          callback 'onFoo', operations: {
            '{$request.query.foo}' => { path: '/bar' }
          }
        end
        callback = definitions.callback('onFoo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      def test_callback_with_block
        definitions = self.definitions do
          callback 'foo' do
            operation '{$request.query.foo}', path: '/bar'
          end
        end
        callback = definitions.callback('foo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      def test_callback_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            callback 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at callback "foo")', error.message)
      end

      # #default

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

      def test_default_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            default 'array', foo: ''
          end
        end
        assert_equal('unsupported keyword: foo (at default "array")', error.message)
      end

      # #example

      def test_example
        definitions = self.definitions do
          example 'foo', value: 'bar'
        end
        example = definitions.example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      def test_example_with_block
        definitions = self.definitions do
          example 'foo' do
            value 'bar'
          end
        end
        example = definitions.example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      def test_example_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            example 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at example "foo")', error.message)
      end

      # #include

      def test_include
        struct = Struct.new(:api_definitions)
        owner1 = struct.new(definitions { schema 'Foo' })
        owner2 = struct.new(definitions { include owner1 })

        schema = owner2.api_definitions.find_schema('Foo')
        assert_predicate(schema, :present?)
      end

      # #header

      def test_header
        definitions = self.definitions do
          header 'foo', description: 'Description of foo'
        end
        header = definitions.header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      def test_header_with_block
        definitions = self.definitions do
          header 'foo' do
            description 'Description of foo'
          end
        end
        header = definitions.header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      def test_header_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            header 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at header "foo")', error.message)
      end

      # #link

      def test_link
        definitions = self.definitions do
          link 'foo', operation_id: 'bar'
        end
        link = definitions.link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      def test_link_with_block
        definitions = self.definitions do
          link 'foo' do
            operation_id 'bar'
          end
        end
        link = definitions.link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      def test_link_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            link 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at link "foo")', error.message)
      end

      # #on_rescue

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

      # #operation

      def test_operation
        # Named operation
        definitions = self.definitions do
          operation 'foo', description: 'Description of foo'
        end
        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)

        # Nameless operation
        definitions = definitions do
          operation description: 'Description of foo'
        end
        operation = definitions.operation
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)
      end

      def test_operation_with_block
        # Named operation
        definitions = self.definitions do
          operation 'foo' do
            description 'Description of foo'
          end
        end
        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)

        # Nameless operation
        definitions = definitions do
          operation do
            description 'Description of foo'
          end
        end
        operation = definitions.operation
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)
      end

      def test_operation_raises_an_error_on_invalid_keyword
        # Named operation
        error = assert_raises(Error) do
          definitions do
            operation 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at operation "foo")', error.message)

        # Nameless operation
        error = assert_raises(Error) do
          definitions do
            operation bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at operation)', error.message)
      end

      # #parameter

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

      def test_parameter_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            parameter 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at parameter "foo")', error.message)
      end

      # #request_body

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

      def test_request_body_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            request_body 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at request_body "foo")', error.message)
      end

      # #rescue_from

      def test_recue_from
        definitions = self.definitions do
          rescue_from StandardError, with: 500
        end
        rescue_handlers = definitions.rescue_handlers
        assert_equal([500], rescue_handlers.map(&:status))
      end

      # #response

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

      def test_response_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            response 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at response "foo")', error.message)
      end

      # #schema

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

      def test_schema_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            schema 'foo', bar: ''
          end
        end
        assert_equal('unsupported keyword: bar (at schema "foo")', error.message)
      end

      # #security_scheme

      def test_security_scheme
        definitions = self.definitions do
          security_scheme 'basic_auth', type: 'http',
                                        scheme: 'basic',
                                        description: 'Description of basic auth'
        end
        security_scheme = definitions.security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      def test_security_scheme_with_block
        definitions = self.definitions do
          security_scheme 'basic_auth', type: 'http', scheme: 'basic' do
            description 'Description of basic auth'
          end
        end
        security_scheme = definitions.security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      def test_security_scheme_raises_an_error_on_invalid_keyword
        error = assert_raises(Error) do
          definitions do
            security_scheme 'basic_auth', type: 'http', foo: ''
          end
        end
        assert_equal(
          'unsupported keyword: foo (at security_scheme "basic_auth")',
          error.message
        )
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
