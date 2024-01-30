# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_annotations
        parameter_model = Model::Parameter.new('my_parameter')
        Parameter.new(parameter_model).call do
          description 'My description'
          deprecated true
          example 'My example'
        end
        assert_equal(
          {
            name: 'my_parameter',
            description: 'My description',
            deprecated: true,
            example: 'My example'
          },
          parameter_model.to_openapi_parameters.first.except(:required, :schema)
        )
      end

      def test_required
        parameter_model = Model::Parameter.new('my_parameter')
        Parameter.new(parameter_model).call { required true }

        assert(parameter_model.required?)
      end

      def test_delegated_methods
        parameter_model = Model::Parameter.new('my_parameter', type: 'string')
        Parameter.new(parameter_model).call do
          format 'date'
          nullable true
        end
        assert_equal(
          {
            type: 'string',
            format: 'date',
            nullable: true
          },
          parameter_model.to_openapi_parameters.dig(0, :schema)
        )
      end
    end
  end
end
