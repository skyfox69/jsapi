# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of an operation.
    class Operation < Node
      include Callbacks

      # Overrides Object#method to handle +method+ as a keyword.
      def method(method) # :nodoc:
        _keyword(:method, method)
      end

      # Specifies the model class to access top-level parameters by.
      #
      #   model Foo do
      #     def bar
      #       # ...
      #     end
      #   end
      #
      # +klass+ can be any subclass of Model::Base. If block is given, an anonymous class
      # is created that inherits either from +klass+ or Model::Base.
      def model(klass = nil, &block)
        if block
          klass = Class.new(klass || Model::Base)
          klass.class_eval(&block)
        end
        _meta_model.model = klass
      end

      # Defines a parameter or refers a reusable parameter.
      #
      #   # define a parameter
      #   parameter 'foo', type: 'string'
      #
      #   # define a nested parameter
      #   parameter 'foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      #
      #   # refer a reusable parameter
      #   parameter ref: 'foo'
      #
      # Refers the reusable parameter with the same name if neither any keywords nor a
      # block is specified.
      #
      #   parameter 'foo'
      #
      def parameter(name = nil, **keywords, &block)
        _define('parameter', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          parameter_model = _meta_model.add_parameter(name, keywords)
          _eval(parameter_model, Parameter, &block)
        end
      end

      # Defines the request body or refers a reusable request body.
      #
      #   # define a request body
      #   request_body type: 'object' do
      #     property 'foo', type: 'string'
      #   end
      #
      #   # refer a reusable request body
      #   request_body ref: 'foo'
      #
      # Refers the reusable request body with the same name if neither any
      # keywords nor a block is specified.
      #
      #   request_body 'foo'
      #
      def request_body(**keywords, &block)
        _define('request body') do
          _meta_model.request_body = keywords
          _eval(_meta_model.request_body, RequestBody, &block)
        end
      end

      # Defines a response or refers a reusable response.
      #
      #   # define a response
      #   response 200, type: 'object' do
      #     property 'foo', type: 'string'
      #   end
      #
      #   # refer a reusable response
      #   response 200, ref: 'foo'
      #
      # The default status is <code>"default"</code>.
      #
      # Refers the reusable response with the same name if neither any keywords
      # nor a block is specified.
      #
      #   response 'foo'
      #
      # Raises an Error if name is specified together with keywords or a block.
      def response(status_or_name = nil, name = nil, **keywords, &block)
        _define('response', status_or_name&.inspect) do
          raise Error, 'name cannot be specified together with keywords ' \
                       'or a block' if name && (keywords.any? || block)

          if keywords.any? || block
            status = status_or_name
          else
            status = status_or_name if name
            keywords = { ref: name || status_or_name }
          end
          response_model = _meta_model.add_response(status, keywords)
          _eval(response_model, Response, &block)
        end
      end
    end
  end
end
