# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class BaseReferenceTest < Minitest::Test
      def test_reference_predicate
        assert_predicate(BaseReference.new, :reference?)
      end

      def test_resolve_recursively
        definitions = Definitions.new
        schema = definitions.add_schema('foo')
        definitions.add_schema('bar', ref: 'foo')

        reference = Schema::Reference.new(ref: 'bar')
        assert_equal(schema, reference.resolve(definitions))
      end

      def test_resolve_raises_an_exception_if_it_could_not_be_resolved
        definitions = Definitions.new
        reference = Schema::Reference.new(ref: 'foo')

        error = assert_raises(ReferenceError) do
          reference.resolve(definitions)
        end
        assert_equal("reference can't be resolved: 'foo'", error.message)
      end
    end
  end
end
