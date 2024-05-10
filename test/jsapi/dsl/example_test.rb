# frozen_string_literal: true

module Jsapi
  module DSL
    class ExampleTest < Minitest::Test
      def test_default_example
        Parameter.new(parameter_model) { example 'foo' }
        assert_equal('foo', parameter_model.examples['default'].value)
      end

      def test_example_with_options
        Parameter.new(parameter_model) { example value: 'foo' }
        assert_equal('foo', parameter_model.examples['default'].value)
      end

      def test_example_with_block
        Parameter.new(parameter_model) do
          example { value 'foo' }
        end
        assert_equal('foo', parameter_model.examples['default'].value)
      end

      def test_example_with_name_and_options
        Parameter.new(parameter_model) do
          example 'foo', value: 'bar'
        end
        assert_equal('bar', parameter_model.examples['foo'].value)
      end

      def test_example_with_name_and_block
        Parameter.new(parameter_model) do
          example 'foo' do
            value 'bar'
          end
        end
        assert_equal('bar', parameter_model.examples['foo'].value)
      end

      private

      def parameter_model
        @parameter_model ||= Meta::Parameter.new('parameter')
      end
    end
  end
end
