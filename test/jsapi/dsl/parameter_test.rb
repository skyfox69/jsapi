# frozen_string_literal: true

module Jsapi
  module DSL
    class ParameterTest < Minitest::Test
      def test_description
        parameter = Meta::Parameter.new('parameter')
        Parameter.new(parameter).call { description 'Foo' }
        assert_equal('Foo', parameter.description)
      end

      def test_example
        parameter = Meta::Parameter.new('parameter')
        Parameter.new(parameter).call { example value: 'foo' }
        assert_equal('foo', parameter.examples['default'].value)
      end

      def test_example_with_block
        parameter = Meta::Parameter.new('parameter')
        Parameter.new(parameter).call do
          example { value 'foo' }
        end
        assert_equal('foo', parameter.examples['default'].value)
      end

      def test_deprecated
        parameter = Meta::Parameter.new('parameter')
        Parameter.new(parameter).call { deprecated true }
        assert(parameter.deprecated?)
      end

      def test_delegates_to_schema
        parameter = Meta::Parameter.new('parameter', type: 'string')
        Parameter.new(parameter).call { format 'date' }
        assert_equal('date', parameter.schema.format)
      end
    end
  end
end
