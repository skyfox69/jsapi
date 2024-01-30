# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ParametersTest < Minitest::Test
      include DSL
      include Methods

      attr_accessor :params

      api_path '/my_path' do
        operation :get, 'my_operation' do
          parameter :my_parameter, type: 'integer', minimum: 0
        end
      end

      def test_attribute_reader
        assert_equal(1, my_operation_parameters(1).my_parameter)
      end

      def test_attribute_reader_on_invalid_name
        assert_raises(NoMethodError) { my_operation_parameters.foo }
      end

      def test_bracket_operator
        assert_equal(1, my_operation_parameters(1)['my_parameter'])
      end

      def test_positive_validation
        assert_predicate(my_operation_parameters(0), :valid?)
      end

      def test_negative_validation
        assert_predicate(my_operation_parameters(-1), :invalid?)
      end

      def test_respond_to
        assert(my_operation_parameters.respond_to?(:my_parameter))
      end

      def test_respond_to_on_invalid_name
        assert(!my_operation_parameters.respond_to?(:foo))
      end

      private

      def my_operation_parameters(my_parameter = nil)
        Parameters.new(
          { 'my_parameter' => my_parameter },
          api_definitions.operation(:my_operation),
          api_definitions
        )
      end
    end
  end
end
