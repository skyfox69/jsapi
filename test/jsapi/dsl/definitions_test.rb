# frozen_string_literal: true

module Jsapi
  module DSL
    class DefinitionsTest < Minitest::Test
      class Foo
        extend ClassMethods
        api_definitions do
          schema 'foo', type: 'object'
        end
      end

      class Bar
        extend ClassMethods
        api_definitions do
          include Foo
          openapi '3.0.3' do
            info name: 'Bar API', version: '1.0'
          end
        end
      end

      def test_include
        assert_predicate(Bar.api_definitions.schema(:foo), :present?)
      end

      def test_info
        assert_equal(
          { name: 'Bar API', version: '1.0' },
          Bar.api_definitions.openapi_document('3.0.3')[:info]
        )
      end
    end
  end
end
