# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ParameterTest < Minitest::Test
      def test_new
        parameter = Parameter.new('foo', type: 'string')
        assert_kind_of(Parameter::Base, parameter)
      end

      def test_reference
        reference = Parameter.reference('foo')
        assert_kind_of(Parameter::Reference, reference)
      end
    end
  end
end
