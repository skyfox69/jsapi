# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      # Used to specify details of an \OpenAPI object.
      class Root < Node
        include Callbacks

        ##
        # :method: base_path
        # :args: arg
        # Specifies the base path of the API.
        #
        #   base_path '/foo'
        #
        # See Meta::OpenAPI::Root#base_path for further information.

        ##
        # :method: consumes
        # :args: mime_types
        # Specifies one or more MIME types the API can consume.
        #
        #   consumes 'application/json'
        #
        #   consumes %w[application/json application/pdf]
        #
        # See Meta::OpenAPI::Root#consumes for further information.

        ##
        # :method: external_docs
        # :args: **keywords, &block
        # Specifies the external documentation.
        #
        #   external_docs url: 'https://foo.bar'
        #
        # See Meta::OpenAPI::Root#external_docs for further information.

        ##
        # :method: host
        # :args: arg
        # Specifies the host serving the API.
        #
        #   host 'foo.bar'
        #
        # See Meta::OpenAPI::Root#host for further information.

        ##
        # :method: info
        # :args: **keywords, &block
        # Specifies general information about the API.
        #
        #   info title: 'foo', version: 1
        #
        # See Meta::OpenAPI::Root#info for further information.

        ##
        # :method: link
        # :args: name, **keywords, &block
        # Adds a link.
        #
        #   link 'foo', operation_id: 'bar'
        #
        # See Meta::OpenAPI::Root#links for further information.

        ##
        # :method: produces
        # :args: mime_types
        # Specifies one or more MIME types the API can produce.
        #
        #   produces 'application/json'
        #
        #   produces %w[application/json application/pdf]'
        #
        # See Meta::OpenAPI::Root#produces for further information.

        ##
        # :method: scheme
        # :args: arg
        # Adds a URI scheme supported by the API.
        #
        #   scheme 'https'
        #
        # See Meta::OpenAPI::Root#scheme for further information.

        ##
        # :method: security_requirement
        # :args: **keywords, &block
        # Adds a security requirement.
        #
        #   security_requirement do
        #     scheme 'basic_auth'
        #   end
        #
        # See Meta::OpenAPI::Root#security_requirements for further information.

        ##
        # :method: security_scheme
        # :args: name, **keywords, &block
        # Adds a security scheme.
        #
        #   security_scheme 'basic_auth', type: 'http', scheme: 'basic'
        #
        # See Meta::OpenAPI::Root#security_schemes for further information.

        ##
        # :method: server
        # :args: arg
        # Adds a server providing the API.
        #
        #   server url: 'https://foo.bar'
        #
        # See Meta::OpenAPI::Root#servers for further information.

        ##
        # :method: tag
        # :args: **keywords, &block
        # Adds a tag.
        #
        #   tag name: 'foo', description: 'description of foo'
        #
        # See Meta::OpenAPI::Root#tags for further information.
      end
    end
  end
end
