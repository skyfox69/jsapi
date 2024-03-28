# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of an operation.
    class Operation < Node

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
      # Refers to the reusable parameter with the same name if neither
      # any options nor a block is specified.
      #
      #   parameter 'foo'
      #
      # Nested object parameters can be defined within the block.
      #
      #   parameter 'foo' do
      #     property 'bar', type: 'string'
      #   end
      #
      # ==== Options
      #
      # [+:schema+]
      #   The referred schema. The value must be the name of a schema defined
      #   by Definitions#schema. +:schema+ cannot be specified together with
      #   +:type+, +:default+, +:conversion+, +:model+, +:items+, +:format+,
      #   and validations.
      # [+:type+]
      #   The type of the parameter. See Meta::Schema for details.
      # [+:existence+]
      #   The level of existence. See Meta::Existence for details.
      # [+:default+]
      #   The default value.
      # [+:conversion+]
      #   The method or +Proc+ to convert a parameter value by.
      #     parameter 'foo', type: 'string', conversion: :upcase
      # [+:model+]
      #   The model class to access nested object parameters by. The default
      #   model class is Model::Base.
      # [+:items+]
      #   The kind of items that can be contained in an array.
      #     parameter 'foo', type: 'array', items: { type: 'string' }
      # [+:format+]
      #   The string format. Possible values are <code>'date'</code> and
      #   <code>'date-time'</code>. Parameter values are implictly casted to
      #   an instance of +Date+ or +DateTime+ if format is specified.
      #     parameter 'foo', type: 'string', format: 'date'
      #
      # ===== Annotations
      #
      # [+:in+]
      #   The location of the parameter. Possible values are <code>'path'</code>
      #   and <code>'query'</code>. The default value is <code>'query'</code>.
      # [+:description+]
      #   A description of the parameter.
      # [+:example+]
      #   A sample parameter value. See Example#example for details.
      # [+:deprecated+]
      #   Specifies whether or not the parameter is deprecated.
      #
      # ===== Validations
      #
      # [+:enum+]
      #   The valid values.
      # [+:minimum+]
      #   The minimum value of an integer or a number.
      #     parameter 'foo', type: 'integer', minimum: 0
      #     parameter 'bar', type: 'number', minimum: { value: 0, exclusive: true }
      # [+:maximum+]
      #   The maximum value of an integer or a number.
      #     parameter 'foo', type: 'integer', maximum: 1
      #     parameter 'bar', type: 'number', maximum: { value: 1, exclusive: true }
      # [+:multiple_of+]
      #   The value an integer or a number must be a multiple of.
      #     parameter 'foo', type: 'integer', multiple_of: 2
      #     parameter 'bar', type: 'number', multiple_of: 0.5
      # [+:min_length+]
      #   The minimum length of a string.
      #     parameter 'foo', type: 'string', min_length: 2
      # [+:max_length+]
      #   The maximum length of a string.
      #     parameter 'foo', type: 'string', max_length: 3
      # [+:pattern+]
      #   The regular expression a string must match.
      #     parameter 'foo', type: 'string', pattern: /^[a-z]+$/
      # [+:min_items+]
      #   The minimum length of an array.
      #     parameter 'foo', type: 'array', min_items: 2
      # [+:max_items+]
      #   The maximum length of an array.
      #     parameter 'foo', type: 'array', max_items: 3
      #
      def parameter(name, **options, &block)
        node("'#{name}'") do
          if options.any? || block
            parameter_model = _meta_model.add_parameter(name, **options)
            Parameter.new(parameter_model).call(&block) if block
          else
            _meta_model.add_parameter_reference(name)
          end
        end
      end

      # Defines the request body.
      #
      #   request_body do
      #     property 'bar', type: 'string'
      #   end
      #
      # ==== Options
      #
      # [+:schema+]
      #   The referred schema. The value must be the name of a schema defined
      #   by Definitions#schema.
      # [+:existence+]
      #   The level of existence. See Meta::Existence for details.
      # [+:default+]
      #   The default value.
      #
      # ===== Annotations
      #
      # [+:description+]
      #   A description of the request body.
      # [+:example+]
      #   A sample parameter value. See Example#example for details.
      # [+:deprecated+]
      #   Specifies whether or not the request body is deprecated.
      #
      def request_body(**options, &block)
        node('request body') do
          request_body = _meta_model.set_request_body(**options)
          RequestBody.new(request_body).call(&block) if block
        end
      end

      # Defines a response. This method can be used to define a response in
      # place or to refer a reusable response.
      #
      #   response 200 do
      #     property 'bar', type: 'string'
      #   end
      #
      # The default status is <code>'default'</code>.
      #
      # Refers to the reusable response with the same name if neither any
      # options nor a block is specified.
      #
      #   response 200, 'Foo'
      #
      # ==== Options
      #
      # [+:schema+]
      #   The referred schema. The value must be the name of a schema defined
      #   by Definitions#schema. +:schema+ cannot be specified together with
      #   +:type+, +:items+, and +:format+.
      # [+:type+]
      #   The type of the response. See Meta::Schema for details.
      # [+:existence+]
      #   The level of existence. See Meta::Existence for details.
      # [+:locale+]
      #   The locale used when rendering a response. The +:locale+ option can
      #   be used to choice different languages for regular and error responses.
      # [+:items+]
      #   The kind of items that can be contained in an array response.
      # [+:format+]
      #   The format of a string response. Possible values are <code>'date'</code>
      #   and <code>'date-time'</code>. If specified, the value to be returned is
      #   casted to an instance of +Date+ or +DateTime+ when rendering the
      #   response.
      #
      # ===== Annotations
      #
      # [+:description+]
      #   A description of the response.
      # [+:example+]
      #   A sample response. See Example#example for details.
      # [+:deprecated+]
      #   Specifies whether or not the response is deprecated.
      #
      def response(status_or_name = nil, name = nil, **options, &block)
        node('response', status_or_name) do
          if options.any? || block
            raise Error, 'name cannot be specified together with options ' \
                         'or a block' if name

            response_model = _meta_model.add_response(status_or_name, **options)
            Response.new(response_model).call(&block) if block
          else
            status = status_or_name if name
            name ||= status_or_name

            _meta_model.add_response_reference(status, name)
          end
        end
      end
    end
  end
end
