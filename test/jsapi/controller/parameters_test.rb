# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Controller
    class ParametersTest < Minitest::Test
      def test_unpermitted_parameters
        assert_raises(ActionController::UnpermittedParameters) do
          parameters(foo: 'bar')
        end
      end

      # Attribute reader tests

      def test_bracket_operator
        assert_equal(1, parameters(my_parameter: 1)['my_parameter'])
      end

      def test_bracket_operator_on_nil
        assert_nil(parameters[nil])
      end

      def test_attr_reader
        assert_equal(1, parameters(my_parameter: 1).my_parameter)
      end

      def test_attr_reader_on_invalid_name
        assert_raises(NoMethodError) { parameters.foo }
      end

      def test_respond_to
        assert(parameters.respond_to?(:my_parameter))
      end

      def test_respond_to_on_invalid_name
        assert(!parameters.respond_to?(:foo))
      end

      # Validation tests

      def test_positive_validation
        assert_predicate(parameters(my_parameter: 0), :valid?)
      end

      def test_negative_validation
        assert_predicate(parameters(my_parameter: -1), :invalid?)
      end

      private

      def definitions
        @definitions ||= Model::Definitions.new.tap do |definitions|
          operation = definitions.add_operation('my_operation')
          operation.add_parameter('my_parameter', type: 'integer', minimum: 0)
        end
      end

      def parameters(**args)
        params = ActionController::Parameters.new(**args)
        Parameters.new(params, definitions.operation, definitions)
      end
    end
  end
end
