# frozen_string_literal: true

module Jsapi
  module DSL
    class PropertyTest < Minitest::Test
      def test_description
        property_model = Model::Property.new('my_property', type: 'string')
        Property.new(property_model).call { description 'My description' }
        assert_equal('My description', property_model.schema.description)
      end

      def test_example
        property_model = Model::Property.new('my_property', type: 'string')
        Property.new(property_model).call { example 'My example' }
        assert_equal('My example', property_model.schema.example)
      end

      def test_deprecated
        property_model = Model::Property.new('my_property')
        Property.new(property_model).call { deprecated true }
        assert(property_model.deprecated?)
      end

      def test_delegated_method
        property_model = Model::Property.new('my_property', type: 'string')
        Property.new(property_model).call { format 'date' }
        assert_equal('date', property_model.schema.format)
      end
    end
  end
end
