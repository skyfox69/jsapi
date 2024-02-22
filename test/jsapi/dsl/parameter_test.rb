# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_description
        parameter_model = Model::Parameter.new('my_parameter')
        Parameter.new(parameter_model).call { description 'My description' }
        assert_equal('My description', parameter_model.description)
      end

      def test_example
        parameter_model = Model::Parameter.new('my_parameter')
        Parameter.new(parameter_model).call { example 'My example' }
        assert_equal('My example', parameter_model.example)
      end

      def test_deprecated
        parameter_model = Model::Parameter.new('my_parameter')
        Parameter.new(parameter_model).call { deprecated true }
        assert(parameter_model.deprecated?)
      end

      def test_delegated_method
        parameter_model = Model::Parameter.new('my_parameter', type: 'string')
        Parameter.new(parameter_model).call { format 'date' }
        assert_equal('date', parameter_model.schema.format)
      end
    end
  end
end
