# frozen_string_literal: true

module Jsapi
  module DSL
    class PropertyTest < Minitest::Test
      def test_deprecated
        property_model = Model::Property.new('my_property')
        Property.new(property_model).call { deprecated true }

        assert(property_model.deprecated?)
      end

      def test_required
        property_model = Model::Property.new('my_property')
        Property.new(property_model).call { required true }

        assert(property_model.required?)
      end

      def test_delegated_methods
        property_model = Model::Property.new('my_property', type: 'string')
        Property.new(property_model).call do
          description 'My description'
          example 'My example'
          format 'date'
          nullable true
        end
        assert_equal(
          {
            type: 'string',
            description: 'My description',
            example: 'My example',
            format: 'date',
            nullable: true
          },
          property_model.to_openapi_schema.except
        )
      end
    end
  end
end
