# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_description
        parameter_model = Model::Parameter.new('parameter')
        Parameter.new(parameter_model).call { description 'Foo' }
        assert_equal('Foo', parameter_model.description)
      end

      def test_example
        parameter_model = Model::Parameter.new('parameter')
        Parameter.new(parameter_model).call { example value: 'foo' }
        assert_equal('foo', parameter_model.examples['default'].value)
      end

      def test_example_with_block
        parameter_model = Model::Parameter.new('parameter')
        Parameter.new(parameter_model).call do
          example { value 'foo' }
        end
        assert_equal('foo', parameter_model.examples['default'].value)
      end

      def test_deprecated
        parameter_model = Model::Parameter.new('parameter')
        Parameter.new(parameter_model).call { deprecated true }
        assert(parameter_model.deprecated?)
      end

      def test_delegated_method
        parameter_model = Model::Parameter.new('parameter', type: 'string')
        Parameter.new(parameter_model).call { format 'date' }
        assert_equal('date', parameter_model.schema.format)
      end
    end
  end
end
