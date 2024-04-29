# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class PropertyTest < Minitest::Test
      def test_initialize
        property = Property.new('foo', type: 'string')
        assert_equal('foo', property.name)
        assert_equal('string', property.type)
      end

      def test_raises_exception_on_blank_name
        error = assert_raises(ArgumentError) { Property.new('') }
        assert_equal("property name can't be blank", error.message)
      end

      # Predicate methods tests

      def test_required_predicate
        property = Property.new('foo', existence: true)
        assert(property.required?)

        property = Property.new('foo', existence: false)
        assert(!property.required?)
      end
    end
  end
end
