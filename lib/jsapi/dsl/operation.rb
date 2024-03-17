# frozen_string_literal: true

module Jsapi
  module DSL
    class Operation < Node
      def model(klass = nil, &block)
        if block
          klass = Class.new(klass || Model::Base)
          klass.class_eval(&block)
        end
        _meta_model.model = klass
      end

      # Defines a parameter.
      def parameter(name, **options, &block)
        wrap_error "'#{name}'" do
          if options.any? || block
            parameter_model = _meta_model.add_parameter(name, **options)
            Parameter.new(parameter_model).call(&block) if block
          else
            _meta_model.add_parameter_reference(name)
          end
        end
      end

      # Defines the request body.
      def request_body(**options, &block)
        wrap_error 'request body' do
          request_body = _meta_model.set_request_body(**options)
          RequestBody.new(request_body).call(&block) if block
        end
      end

      # Defines a response. Default status is +default+.
      def response(status = nil, name = nil, **options, &block)
        wrap_error 'response', status do
          if name.nil?
            response_model = _meta_model.add_response(status, **options)
            Response.new(response_model).call(&block) if block
          else
            _meta_model.add_response_reference(status, name)
          end
        end
      end
    end
  end
end
