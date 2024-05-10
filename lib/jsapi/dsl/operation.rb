# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of an operation.
    class Operation < Node

      # Defines a callback. This method can be used to define a callback in
      # place or to refer a reusable callback.
      #
      #   callback 'foo' do
      #     operation '{$request.query.foo}', 'bar'
      #   end
      #
      #   callback ref: 'foo'
      #
      # Refers to the reusable callback with the same name if neither any
      # keywords nor a block is specified.
      def callback(name = nil, **keywords, &block)
        define('callback', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          callback_model = _meta_model.add_callback(name, keywords)
          Node.new(callback_model, &block) if block
        end
      end

      # Overrides Object#method
      def method(method) # :nodoc:
        method_missing(:method, method)
      end

      # Specifies the model class to access top-level parameters by.
      #
      #   model Foo do
      #     def bar
      #       # ...
      #     end
      #   end
      #
      # +klass+ can be any subclass of Model::Base. If block is given, an
      # anonymous class is created that inherits either from +klass+ or
      # Model::Base.
      def model(klass = nil, &block)
        if block
          klass = Class.new(klass || Model::Base)
          klass.class_eval(&block)
        end
        _meta_model.model = klass
      end

      # Defines a parameter. This method can be used to define a parameter
      # in place or to refer a reusable parameter.
      #
      #   parameter 'foo', type: 'string'
      #
      #   parameter ref: 'foo'
      #
      # Nested object parameters can be defined within the block.
      #
      #   parameter 'foo' do
      #     property 'bar', type: 'string'
      #   end
      #
      # Refers to the reusable parameter with the same name if neither
      # any keywords nor a block is specified.
      def parameter(name = nil, **keywords, &block)
        define('parameter', name&.inspect) do
          name = keywords[:ref] if name.nil?
          keywords = { ref: name } unless keywords.any? || block

          parameter_model = _meta_model.add_parameter(name, keywords)
          Parameter.new(parameter_model, &block) if block
        end
      end

      # Defines the request body.
      #
      #   request_body do
      #     property 'foo', type: 'string'
      #   end
      def request_body(**keywords, &block)
        define('request body') do
          _meta_model.request_body = keywords
          RequestBody.new(_meta_model.request_body, &block) if block
        end
      end

      # Defines a response. This method can be used to define a response in
      # place or to refer a reusable response.
      #
      #   response 200 do
      #     property 'foo', type: 'string'
      #   end
      #
      #   response 200, ref: 'foo'
      #
      # The default status is <code>"default"</code>.
      #
      # Refers to the reusable response with the same name if neither any
      # keywords nor a block is specified.
      #
      # Raises an Error if name is specified together with keywords or a block.
      def response(status_or_name = nil, name = nil, **keywords, &block)
        define('response', status_or_name&.inspect) do
          raise Error, 'name cannot be specified together with keywords ' \
                       'or a block' if name && (keywords.any? || block)

          if keywords.any? || block
            status = status_or_name
          else
            status = status_or_name if name
            keywords = { ref: name || status_or_name }
          end
          response_model = _meta_model.add_response(status, keywords)
          Response.new(response_model, &block) if block
        end
      end
    end
  end
end
