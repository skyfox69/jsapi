# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
      # ::api_base_path

      def test_api_base_path
        definitions = Class.new do
          extend ClassMethods
          api_base_path '/foo'
        end.api_definitions

        assert_equal('/foo', definitions.base_path)
      end

      # ::api_callback

      def test_api_callback
        definitions = Class.new do
          extend ClassMethods
          api_callback 'onFoo', operations: {
            '{$request.query.foo}' => { path: '/bar' }
          }
        end.api_definitions

        callback = definitions.callback('onFoo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      def test_api_callback_with_block
        definitions = Class.new do
          extend ClassMethods
          api_callback 'onFoo' do
            operation '{$request.query.foo}', path: '/bar'
          end
        end.api_definitions

        callback = definitions.callback('onFoo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      # ::api_default

      def test_api_default
        definitions = Class.new do
          extend ClassMethods
          api_default 'array', within_responses: []
        end.api_definitions

        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.within_responses)
      end

      def test_api_default_with_block
        definitions = Class.new do
          extend ClassMethods
          api_default 'array' do
            within_responses []
          end
        end.api_definitions

        default = definitions.default('array')
        assert_predicate(default, :present?)
        assert_equal([], default.within_responses)
      end

      # ::api_definitions

      def test_api_definitions
        base_klass = Class.new do
          extend ClassMethods
        end
        klass = Class.new(base_klass)
        definitions = klass.api_definitions

        assert_equal(klass, definitions.owner)
        assert_equal(base_klass, definitions.parent.owner)
      end

      def test_api_definitions_with_block
        definitions = Class.new do
          extend ClassMethods
          api_definitions do
            operation 'foo'
          end
        end.api_definitions

        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
      end

      # ::api_example

      def test_api_example
        definitions = Class.new do
          extend ClassMethods
          api_example 'foo', value: 'bar'
        end.api_definitions

        example = definitions.example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      def test_api_example_with_block
        definitions = Class.new do
          extend ClassMethods
          api_example 'foo' do
            value 'bar'
          end
        end.api_definitions

        example = definitions.example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      # ::api_external_docs

      def test_api_external_docs
        definitions = Class.new do
          extend ClassMethods
          api_external_docs url: 'https://foo.bar'
        end.api_definitions

        external_docs = definitions.external_docs
        assert_predicate(external_docs, :present?)
        assert_equal('https://foo.bar', external_docs.url)
      end

      def test_api_external_docs_with_block
        definitions = Class.new do
          extend ClassMethods
          api_external_docs do
            url 'https://foo.bar'
          end
        end.api_definitions

        external_docs = definitions.external_docs
        assert_predicate(external_docs, :present?)
        assert_equal('https://foo.bar', external_docs.url)
      end

      # ::api_header

      def test_api_header
        definitions = Class.new do
          extend ClassMethods
          api_header 'foo', description: 'Description of foo'
        end.api_definitions

        header = definitions.header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      def test_api_header_with_block
        definitions = Class.new do
          extend ClassMethods
          api_header 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        header = definitions.header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      # ::api_host

      def test_api_host
        definitions = Class.new do
          extend ClassMethods
          api_host 'foo.bar'
        end.api_definitions

        assert_equal('foo.bar', definitions.host)
      end

      # ::api_include

      def test_api_include
        foo_class = Class.new do
          extend ClassMethods
          api_schema 'foo'
        end
        bar_class = Class.new do
          extend ClassMethods
          api_include foo_class
        end
        definitions = bar_class.api_definitions

        schema = definitions.find_schema('foo')
        assert_predicate(schema, :present?)
      end

      # ::api_info

      def test_api_info
        definitions = Class.new do
          extend ClassMethods
          api_info title: 'foo'
        end.api_definitions

        info = definitions.info
        assert_predicate(info, :present?)
        assert_equal('foo', info.title)
      end

      def test_api_info_with_block
        definitions = Class.new do
          extend ClassMethods
          api_info do
            title 'foo'
          end
        end.api_definitions

        info = definitions.info
        assert_predicate(info, :present?)
        assert_equal('foo', info.title)
      end

      # ::api_link

      def test_api_link
        definitions = Class.new do
          extend ClassMethods
          api_link 'foo', operation_id: 'bar'
        end.api_definitions

        link = definitions.link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      def test_api_link_with_block
        definitions = Class.new do
          extend ClassMethods
          api_link 'foo' do
            operation_id 'bar'
          end
        end.api_definitions

        link = definitions.link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      # ::api_on_rescue

      def test_api_on_rescue
        definitions = Class.new do
          extend ClassMethods
          api_on_rescue :foo
        end.api_definitions

        assert_equal(:foo, definitions.on_rescue_callbacks.first)
      end

      def test_api_on_rescue_with_block
        definitions = Class.new do
          extend ClassMethods
          api_on_rescue { |e| e }
        end.api_definitions

        assert_instance_of(Proc, definitions.on_rescue_callbacks.first)
      end

      # ::api_operation

      def test_api_operation
        definitions = Class.new do
          extend ClassMethods
          api_operation 'foo', description: 'Description of foo'
        end.api_definitions

        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)
      end

      def test_api_operation_with_block
        definitions = Class.new do
          extend ClassMethods
          api_operation 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        operation = definitions.operation('foo')
        assert_predicate(operation, :present?)
        assert_equal('Description of foo', operation.description)
      end

      # ::api_parameter

      def test_api_parameter
        definitions = Class.new do
          extend ClassMethods
          api_parameter 'foo', description: 'Description of foo'
        end.api_definitions

        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('Description of foo', parameter.description)
      end

      def test_api_parameter_with_block
        definitions = Class.new do
          extend ClassMethods
          api_parameter 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        parameter = definitions.parameter('foo')
        assert_predicate(parameter, :present?)
        assert_equal('Description of foo', parameter.description)
      end

      # ::api_request_body

      def test_api_request_body
        definitions = Class.new do
          extend ClassMethods
          api_request_body 'foo', description: 'Description of foo'
        end.api_definitions

        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('Description of foo', request_body.description)
      end

      def test_api_request_body_with_block
        definitions = Class.new do
          extend ClassMethods
          api_request_body 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        request_body = definitions.request_body('foo')
        assert_predicate(request_body, :present?)
        assert_equal('Description of foo', request_body.description)
      end

      # ::api_rescue_from

      def test_api_rescue_from
        definitions = Class.new do
          extend ClassMethods
          api_rescue_from StandardError
        end.api_definitions

        rescue_handler = definitions.rescue_handler_for(StandardError.new)
        assert_predicate(rescue_handler, :present?)
      end

      # ::api_response

      def test_api_response
        definitions = Class.new do
          extend ClassMethods
          api_response 'foo', description: 'Description of foo'
        end.api_definitions

        response = definitions.response('foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      def test_api_response_with_block
        definitions = Class.new do
          extend ClassMethods
          api_response 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        response = definitions.response('foo')
        assert_predicate(response, :present?)
        assert_equal('Description of foo', response.description)
      end

      # ::api_schema

      def test_api_schema
        definitions = Class.new do
          extend ClassMethods
          api_schema 'foo', description: 'Description of foo'
        end.api_definitions

        schema = definitions.schema('foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      def test_api_schema_with_block
        definitions = Class.new do
          extend ClassMethods
          api_schema 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        schema = definitions.schema('foo')
        assert_predicate(schema, :present?)
        assert_equal('Description of foo', schema.description)
      end

      # ::api_scheme

      def test_api_scheme
        definitions = Class.new do
          extend ClassMethods
          api_scheme 'https'
        end.api_definitions

        assert_equal(%w[https], definitions.schemes)
      end

      # ::api_security_requirement

      def test_api_security_requirement
        definitions = Class.new do
          extend ClassMethods
          api_security_requirement schemes: { 'basic_auth' => [] }
        end.api_definitions

        security_requirements = definitions.security_requirements
        assert_predicate(security_requirements, :one?)
        assert_equal([], security_requirements.first.schemes['basic_auth'].scopes)
      end

      def test_api_security_requirement_with_block
        definitions = Class.new do
          extend ClassMethods
          api_security_requirement do
            scheme 'basic_auth'
          end
        end.api_definitions

        security_requirements = definitions.security_requirements
        assert_predicate(security_requirements, :one?)
        assert_equal([], security_requirements.first.schemes['basic_auth'].scopes)
      end

      # ::api_security_scheme

      def test_api_security_scheme
        definitions = Class.new do
          extend ClassMethods
          api_security_scheme 'basic_auth', type: 'http',
                                            scheme: 'basic',
                                            description: 'Description of basic auth'
        end.api_definitions

        security_scheme = definitions.security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      def test_api_security_scheme_with_block
        definitions = Class.new do
          extend ClassMethods
          api_security_scheme 'basic_auth', type: 'http', scheme: 'basic' do
            description 'Description of basic auth'
          end
        end.api_definitions

        security_scheme = definitions.security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      # ::api_server

      def test_api_server
        definitions = Class.new do
          extend ClassMethods
          api_server url: 'https://foo.bar/foo'
        end.api_definitions

        servers = definitions.servers
        assert_predicate(servers, :one?)
        assert_equal('https://foo.bar/foo', servers.first.url)
      end

      def test_api_server_with_block
        definitions = Class.new do
          extend ClassMethods
          api_server do
            url 'https://foo.bar/foo'
          end
        end.api_definitions

        servers = definitions.servers
        assert_predicate(servers, :one?)
        assert_equal('https://foo.bar/foo', servers.first.url)
      end

      # ::api_tag

      def test_api_tag
        definitions = Class.new do
          extend ClassMethods
          api_tag name: 'foo'
        end.api_definitions

        tags = definitions.tags
        assert_predicate(tags, :one?)
        assert_equal('foo', tags.first.name)
      end

      def test_api_tag_with_block
        definitions = Class.new do
          extend ClassMethods
          api_tag do
            name 'foo'
          end
        end.api_definitions

        tags = definitions.tags
        assert_predicate(tags, :one?)
        assert_equal('foo', tags.first.name)
      end
    end
  end
end
