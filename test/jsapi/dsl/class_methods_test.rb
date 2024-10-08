# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DSL
    class ClassMethodsTest < Minitest::Test
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

      # ::openapi

      def test_openapi
        definitions = Class.new do
          extend ClassMethods
          openapi info: { title: 'foo', version: '1' }
        end.api_definitions

        info = definitions.openapi_info
        assert_predicate(info, :present?)
        assert_equal('foo', info.title)
      end

      def test_openapi_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi do
            info title: 'foo', version: '1'
          end
        end.api_definitions

        info = definitions.openapi_info
        assert_predicate(info, :present?)
        assert_equal('foo', info.title)
      end

      # ::openapi_base_path

      def test_openapi_base_path
        definitions = Class.new do
          extend ClassMethods
          openapi_base_path '/foo'
        end.api_definitions

        assert_equal('/foo', definitions.openapi_base_path)
      end

      # ::openapi_callback

      def test_openapi_callback
        definitions = Class.new do
          extend ClassMethods
          openapi_callback 'onFoo', operations: {
            '{$request.query.foo}' => { path: '/bar' }
          }
        end.api_definitions

        callback = definitions.openapi_callback('onFoo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      def test_openapi_callback_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_callback 'onFoo' do
            operation '{$request.query.foo}', path: '/bar'
          end
        end.api_definitions

        callback = definitions.openapi_callback('onFoo')
        assert_predicate(callback, :present?)
        assert_equal('/bar', callback.operation('{$request.query.foo}').path)
      end

      # ::openapi_example

      def test_openapi_example
        definitions = Class.new do
          extend ClassMethods
          openapi_example 'foo', value: 'bar'
        end.api_definitions

        example = definitions.openapi_example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      def test_openapi_example_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_example 'foo' do
            value 'bar'
          end
        end.api_definitions

        example = definitions.openapi_example('foo')
        assert_predicate(example, :present?)
        assert_equal('bar', example.value)
      end

      # ::openapi_external_docs

      def test_openapi_external_docs
        definitions = Class.new do
          extend ClassMethods
          openapi_external_docs url: 'https://foo.bar'
        end.api_definitions

        external_docs = definitions.openapi_external_docs
        assert_predicate(external_docs, :present?)
        assert_equal('https://foo.bar', external_docs.url)
      end

      def test_openapi_external_docs_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_external_docs do
            url 'https://foo.bar'
          end
        end.api_definitions

        external_docs = definitions.openapi_external_docs
        assert_predicate(external_docs, :present?)
        assert_equal('https://foo.bar', external_docs.url)
      end

      # ::openapi_header

      def test_openapi_header
        definitions = Class.new do
          extend ClassMethods
          openapi_header 'foo', description: 'Description of foo'
        end.api_definitions

        header = definitions.openapi_header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      def test_openapi_header_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_header 'foo' do
            description 'Description of foo'
          end
        end.api_definitions

        header = definitions.openapi_header('foo')
        assert_predicate(header, :present?)
        assert_equal('Description of foo', header.description)
      end

      # ::openapi_host

      def test_openapi_host
        definitions = Class.new do
          extend ClassMethods
          openapi_host 'foo.bar'
        end.api_definitions

        assert_equal('foo.bar', definitions.openapi_host)
      end

      # ::openapi_info

      def test_openapi_info
        definitions = Class.new do
          extend ClassMethods
          openapi_info title: 'foo'
        end.api_definitions

        info = definitions.openapi_info
        assert_predicate(info, :present?)
        assert_equal('foo', info.title)
      end

      def test_openapi_info_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_info do
            title 'foo'
          end
        end.api_definitions

        openapi_info = definitions.openapi_info
        assert_predicate(openapi_info, :present?)
        assert_equal('foo', openapi_info.title)
      end

      # ::openapi_link

      def test_openapi_link
        definitions = Class.new do
          extend ClassMethods
          openapi_link 'foo', operation_id: 'bar'
        end.api_definitions

        link = definitions.openapi_link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      def test_openapi_link_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_link 'foo' do
            operation_id 'bar'
          end
        end.api_definitions

        link = definitions.openapi_link('foo')
        assert_predicate(link, :present?)
        assert_equal('bar', link.operation_id)
      end

      # ::openapi_scheme

      def test_openapi_scheme
        definitions = Class.new do
          extend ClassMethods
          openapi_scheme 'https'
        end.api_definitions

        assert_equal(%w[https], definitions.openapi_schemes)
      end

      # ::openapi_security_requirement

      def test_openapi_security_requirement
        definitions = Class.new do
          extend ClassMethods
          openapi_security_requirement schemes: { 'basic_auth' => [] }
        end.api_definitions

        security_requirements = definitions.openapi_security_requirements
        assert_predicate(security_requirements, :one?)
        assert_equal([], security_requirements.first.schemes['basic_auth'].scopes)
      end

      def test_openapi_security_requirement_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_security_requirement do
            scheme 'basic_auth'
          end
        end.api_definitions

        security_requirements = definitions.openapi_security_requirements
        assert_predicate(security_requirements, :one?)
        assert_equal([], security_requirements.first.schemes['basic_auth'].scopes)
      end

      # ::openapi_security_scheme

      def test_openapi_security_scheme
        definitions = Class.new do
          extend ClassMethods
          openapi_security_scheme 'basic_auth', type: 'http',
                                                scheme: 'basic',
                                                description: 'Description of basic auth'
        end.api_definitions

        security_scheme = definitions.openapi_security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      def test_openapi_security_scheme_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_security_scheme 'basic_auth', type: 'http', scheme: 'basic' do
            description 'Description of basic auth'
          end
        end.api_definitions

        security_scheme = definitions.openapi_security_scheme('basic_auth')
        assert_predicate(security_scheme, :present?)
        assert_equal('Description of basic auth', security_scheme.description)
      end

      # ::openapi_server

      def test_openapi_server
        definitions = Class.new do
          extend ClassMethods
          openapi_server url: 'https://foo.bar/foo'
        end.api_definitions

        servers = definitions.openapi_servers
        assert_predicate(servers, :one?)
        assert_equal('https://foo.bar/foo', servers.first.url)
      end

      def test_openapi_server_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_server do
            url 'https://foo.bar/foo'
          end
        end.api_definitions

        servers = definitions.openapi_servers
        assert_predicate(servers, :one?)
        assert_equal('https://foo.bar/foo', servers.first.url)
      end

      # ::openapi_tag

      def test_openapi_tag
        definitions = Class.new do
          extend ClassMethods
          openapi_tag name: 'foo'
        end.api_definitions

        tags = definitions.openapi_tags
        assert_predicate(tags, :one?)
        assert_equal('foo', tags.first.name)
      end

      def test_openapi_tag_with_block
        definitions = Class.new do
          extend ClassMethods
          openapi_tag do
            name 'foo'
          end
        end.api_definitions

        tags = definitions.openapi_tags
        assert_predicate(tags, :one?)
        assert_equal('foo', tags.first.name)
      end
    end
  end
end
