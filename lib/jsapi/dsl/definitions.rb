# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define top-level API components.
    class Definitions < Node

      # Includes API definitions from +klasses+.
      def include(*klasses)
        klasses.each do |klass|
          _meta_model.include(klass.api_definitions)
        end
      end

      # Defines the root of an OpenAPI document.
      #
      #   openapi '3.1' do
      #     info title: 'Foo', version: 1
      #   end
      def openapi(version = nil, &block)
        node("openapi #{version}") do
          openapi = _meta_model.openapi_root(version)
          Generic.new(openapi).call(&block) if block
        end
      end

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
      #
      # ==== Options
      #
      # [+:model+]
      #   The model class to access top-level parameters by. The default model
      #   class is Model::Base.
      #
      # ===== Annotations
      #
      # [+:method+]
      #   The HTTP verb of the operation. The default value is 'get'.
      # [+:path+]
      #   The relative path of the operation.
      # [+:tags+]
      #   An array of strings used to group operations in an OpenAPI document.
      # [+:summary+]
      #   A short summary of the operation.
      # [+:desciption+]
      #   A description of the operation.
      # [+:deprecated+]
      #   Specifies whether or not the operation is deprecated.
      #
      def operation(name = nil, **options, &block)
        node(name.nil? ? '' : "'#{name}'") do
          operation_model = _meta_model.add_operation(name, **options)
          Operation.new(operation_model).call(&block) if block
        end
      end

      # Defines a reusable parameter.
      #
      #   parameter 'foo', type: 'string'
      #
      # ==== Options
      #
      # Same as Operation#parameter.
      #
      def parameter(name, **options, &block)
        node("'#{name}'") do
          parameter_model = _meta_model.add_parameter(name, **options)
          Parameter.new(parameter_model).call(&block) if block
        end
      end

      # Specifies the HTTP status code of an error response rendered when an
      # exception of any of +klasses+ has been raised.
      #
      #   rescue_from Jsapi::Controller::ParametersInvalid, with: 400
      #
      def rescue_from(*klasses, with: nil)
        klasses.each do |klass|
          _meta_model.add_rescue_handler(klass, status: with)
        end
      end

      # Defines a reusable response.
      #
      #   response 'Foo', type: 'object' do
      #     property 'bar', type: 'string'
      #   end
      #
      # ==== Options
      #
      # Same as Operation#response.
      #
      def response(name, **options, &block)
        node("'#{name}'") do
          response_model = _meta_model.add_response(name, **options)
          Response.new(response_model).call(&block) if block
        end
      end

      # Defines a reusable schema.
      #
      #   schema 'Foo' do
      #     property 'bar', type: 'string'
      #   end
      #
      # ==== Options
      #
      # [+:type+]
      #   The type of the schema. See Meta::Schema for details.
      # [+existence+]
      #   The level of existence. See Meta::Existence for details.
      # [+:model+]
      #   The model class to access nested object parameters by. The
      #   default model class is Model::Base.
      #
      def schema(name, **options, &block)
        node("'#{name}'") do
          schema_model = _meta_model.add_schema(name, **options)
          Schema.new(schema_model).call(&block) if block
        end
      end
    end
  end
end
