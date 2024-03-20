# frozen_string_literal: true

module Jsapi
  module DSL
    class Definitions < Node
      # Includes all of the API definitions from +classes+.
      def include(*classes)
        classes.each { |c| _meta_model.include(c.api_definitions) }
      end

      def openapi(version = nil, &block)
        wrap_error("openapi #{version}") do
          openapi = _meta_model.openapi_root(version)
          Generic.new(openapi).call(&block) if block
        end
      end

      # Defines an API operation.
      #
      # The name of an operation must be unique for a particular controller.
      # It can be +nil+ if the controller handles one API operation only.
      #
      # Example:
      #
      #   api_definitions do
      #     operation 'foo', method: 'get', path: '/foo'
      #   end
      #
      # Options:
      #
      # [+:model+]
      #   The model class associated with the API operation. The value must
      #   be a class that inherits from <tt>Jsapi::Model::Base</tt>.
      # [+:method+]
      #   The HTTP verb of the operation. Default is <tt>'get'</tt>.
      # [+:path+]
      #   The relative path of the operation.
      # [+:tags+]
      #   An array of strings to group operations in OpenAPI documents.
      # [+:summary+]
      #   A short summary of the operation.
      # [+:desciption+]
      #   A description of the operation.
      # [+:deprecated+]
      #  if true, the operation is declared as deprecated.
      #
      def operation(name = nil, **options, &block)
        wrap_error(name.nil? ? '' : "'#{name}'") do
          operation_model = _meta_model.add_operation(name, **options)
          Operation.new(operation_model).call(&block) if block
        end
      end

      # Defines a reusable parameter.
      #
      #   api_definitions do
      #     parameter 'foo', type: 'string'
      #   end
      def parameter(name, **options, &block)
        wrap_error("'#{name}'") do
          parameter_model = _meta_model.add_parameter(name, **options)
          Parameter.new(parameter_model).call(&block) if block
        end
      end

      # Associates one or more excpetion classes with a status code.
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler(klass, status: with)
        end
      end

      # Defines a reusable response.
      #
      #   api_definitions do
      #     response 'Foo', type: 'object'
      #  end
      def response(name, **options, &block)
        wrap_error("'#{name}'") do
          response_model = _meta_model.add_response(name, **options)
          Response.new(response_model).call(&block) if block
        end
      end

      # Defines a reusable schema.
      #
      #   api_definitions do
      #     schema 'Foo', type: 'object'
      #  end
      def schema(name, **options, &block)
        wrap_error("'#{name}'") do
          schema_model = _meta_model.add_schema(name, **options)
          Schema.new(schema_model).call(&block) if block
        end
      end
    end
  end
end
