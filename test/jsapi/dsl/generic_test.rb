# frozen_string_literal: true

module Jsapi
  module DSL
    class GenericTest < Minitest::Test
      def test_generic_child_node
        generic_model = Model::Generic.new
        Generic.new(generic_model).call do
          nested my_keyword: 'My value'
        end
        assert_equal(
          { nested: { myKeyword: 'My value' } },
          generic_model.to_openapi
        )
      end

      def test_respond_to
        generic = Generic.new(Model::Generic.new)
        assert(generic.respond_to?(:foo))
      end
    end
  end
end
