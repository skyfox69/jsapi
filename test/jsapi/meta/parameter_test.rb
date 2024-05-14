# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    class ParameterTest < Minitest::Test
      def test_new_model
        parameter = Parameter.new('foo', type: 'string')
        assert_kind_of(Parameter::Model, parameter)
      end

      def test_new_reference
        parameter = Parameter.new('foo', ref: 'foo')
        assert_kind_of(Parameter::Reference, parameter)
      end
    end
  end
end
