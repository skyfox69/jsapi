# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class NestableTest < Minitest::Test
      class Dummy
        include Nestable

        attr_reader :raw_additional_attributes, :raw_attributes

        def initialize(raw_additional_attributes: {}, raw_attributes: {})
          @raw_additional_attributes = raw_additional_attributes
          @raw_attributes = raw_attributes
        end
      end

      def test_inspect
        assert_equal(
          "#<#{Dummy.name} additional_attributes: {}>",
          Dummy.new.inspect
        )
      end

      def test_inspect_on_attributes
        assert_equal(
          "#<#{Dummy.name} foo: \"bar\", additional_attributes: {}>",
          Dummy.new(raw_attributes: { 'foo' => 'bar' }).inspect
        )
      end

      def test_inspect_on_additional_attributes
        assert_equal(
          "#<#{Dummy.name} additional_attributes: {\"foo\"=>\"bar\"}>",
          Dummy.new(raw_additional_attributes: { 'foo' => 'bar' }).inspect
        )
      end
    end
  end
end
