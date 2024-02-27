# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class PropertyTest < Minitest::Test
      def test_raises_error_on_blank_name
        error = assert_raises(ArgumentError) { Property.new('') }
        assert_equal("property name can't be blank", error.message)
      end

      def test_required
        property = Property.new('foo', existence: true)
        assert(property.required?)
      end

      def test_not_required
        property = Property.new('foo', existence: false)
        assert(!property.required?)
      end
    end
  end
end
