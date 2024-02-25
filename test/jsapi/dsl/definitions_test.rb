# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      def test_include
        foo_class = Class.new do
          extend ClassMethods
          api_definitions do
            schema 'Foo'
          end
        end
        bar_class = Class.new do
          extend ClassMethods
          api_definitions do
            include foo_class
          end
        end
        definitions = bar_class.api_definitions
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      def test_openapi
        Definitions.new(definitions).call do
          openapi('2.0') { info name: 'Foo', version: '1' }
        end
        assert_equal(
          { name: 'Foo', version: '1' },
          definitions.openapi_document('2.0')[:info]
        )
      end

      def test_operation
        Definitions.new(definitions).call { operation 'foo' }
        assert_predicate(definitions.operation('foo'), :present?)
      end

      def test_parameter
        Definitions.new(definitions).call { parameter 'foo' }
        assert_predicate(definitions.parameter('foo'), :present?)
      end

      def test_schema
        Definitions.new(definitions).call { schema 'Foo' }
        assert_predicate(definitions.schema('Foo'), :present?)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new
      end
    end
  end
end
