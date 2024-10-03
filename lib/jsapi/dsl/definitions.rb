# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define top-level API components.
    class Definitions < Node
      ##
      # :method: openapi
      # :args: **keywords, &block
      # Allows \OpenAPI components to be defined without prefix +openapi_+.
      #
      #   openapi base_path: '/foo' do
      #     info title: 'Foo', version: '1'
      #     # ...
      #   end
      scope :openapi

      # Specifies the general default values for +type+.
      #
      #   default 'array', read: [], write: []
      #
      def default(type, **keywords, &block)
        _define('default', type.inspect) do
          default = _meta_model.add_default(type, keywords)
          Node.new(default, &block) if block
        end
      end

      # Includes API definitions from +klasses+.
      def include(*klasses)
        klasses.each do |klass|
          _meta_model.include(klass.api_definitions)
        end
      end

      # Registers a callback to be called when rescuing an exception.
      def on_rescue(method = nil, &block)
        _define('on_rescue') do
          _meta_model.add_on_rescue(method || block)
        end
      end

      ##
      # :method: openapi_base_path
      # :args: arg
      # Specifies the base path of the API.
      #
      #   openapi_base_path '/foo'
      #
      # See Meta::Definitions#openapi_base_path for further information.

      ##
      # :method: openapi_external_docs
      # :args: **keywords, &block
      # Specifies the external documentation.
      #
      #   openapi_external_docs url: 'https://foo.bar'
      #
      # See Meta::Definitions#openapi_external_docs for further information.

      ##
      # :method: openapi_host
      # :args: arg
      # Specifies the host serving the API.
      #
      #   openapi_host 'foo.bar'
      #
      # See Meta::Definitions#openapi_host for further information.

      ##
      # :method: openapi_info
      # :args: **keywords, &block
      # Specifies general information about the API.
      #
      #   openapi_info title: 'foo', version: 1
      #
      # See Meta::Definitions#openapi_info for further information.

      ##
      # :method: openapi_link
      # :args: name, **keywords, &block
      # Adds a link.
      #
      #   openapi_link 'foo', operation_id: 'bar'
      #
      # See Meta::Definitions#openapi_links for further information.

      ##
      # :method: openapi_scheme
      # :args: arg
      # Adds a URI scheme supported by the API.
      #
      #   openapi_scheme 'https'
      #
      # See Meta::Definitions#openapi_schemes for further information.

      ##
      # :method: openapi_security_requirement
      # :args: **keywords, &block
      # Adds a security requirement.
      #
      #   openapi_security_requirement do
      #     scheme 'basic_auth'
      #   end
      #
      # See Meta::Definitions#openapi_security_requirements for further information.

      ##
      # :method: openapi_security_scheme
      # :args: name, **keywords, &block
      # Adds a security scheme.
      #
      #   openapi_security_scheme 'basic_auth', type: 'http', scheme: 'basic'
      #
      # See Meta::Definitions#openapi_security_schemes for further information.

      ##
      # :method: openapi_server
      # :args: arg
      # Adds a server providing the API.
      #
      #   openapi_server url: 'https://foo.bar'
      #
      # See Meta::Definitions#openapi_servers for further information.

      ##
      # :method: openapi_tag
      # :args: **keywords, &block
      # Adds a tag.
      #
      #   openapi_tag name: 'foo', description: 'description of foo'
      #
      # See Meta::Definitions#openapi_tags for further information.

      # Defines an operation.
      #
      #   operation 'foo', path: '/foo' do
      #     parameter 'bar', type: 'string'
      #     response do
      #       property 'foo', type: 'string'
      #     end
      #   end
      #
      # +name+ can be +nil+ if the controller handles one operation only.
      def operation(name = nil, **keywords, &block)
        _define('operation', name&.inspect) do
          operation_model = _meta_model.add_operation(name, keywords)
          Operation.new(operation_model, &block) if block
        end
      end

      # Defines a reusable parameter.
      #
      #   parameter 'foo', type: 'string'
      #
      def parameter(name, **keywords, &block)
        _define('parameter', name.inspect) do
          parameter_model = _meta_model.add_parameter(name, keywords)
          Parameter.new(parameter_model, &block) if block
        end
      end

      # Defines a reusable request body.
      #
      #   request_body 'foo', type: 'string'
      #
      def request_body(name, **keywords, &block)
        _define('request_body', name.inspect) do
          request_body_model = _meta_model.add_request_body(name, keywords)
          RequestBody.new(request_body_model, &block) if block
        end
      end

      # Specifies the HTTP status code of an error response rendered when an exception of
      # any of +klasses+ has been raised.
      #
      #   rescue_from Jsapi::Controller::ParametersInvalid, with: 400
      #
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler({ error_class: klass, status: with })
        end
      end

      # Defines a reusable response.
      #
      #   response 'Foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      def response(name, **keywords, &block)
        _define('response', name.inspect) do
          response_model = _meta_model.add_response(name, keywords)
          Response.new(response_model, &block) if block
        end
      end

      # Defines a reusable schema.
      #
      #   schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      def schema(name, **keywords, &block)
        _define('schema', name.inspect) do
          schema_model = _meta_model.add_schema(name, keywords)
          Schema.new(schema_model, &block) if block
        end
      end
    end
  end
end
