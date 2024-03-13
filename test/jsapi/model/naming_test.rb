# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class NamingTest < Minitest::Test
      def setup
        Class.define_method(:module_parents) do
          [Jsapi::Model, Jsapi]
        end
        Module.define_method(:use_relative_model_naming?) do
          true
        end
      end

      def teardown
        Class.undef_method(:module_parents)
        Module.undef_method(:use_relative_model_naming?)
      end

      def test_model_name
        model_name = Base.model_name
        assert_equal(Base, model_name.klass)
        assert_equal(Jsapi::Model, model_name.namespace)
      end

      def test_model_name_on_anonymous_class
        klass = Class.new(Base) do
          extend Naming
        end
        model_name = klass.model_name
        assert_equal(Base, model_name.klass)
        assert_equal(Jsapi::Model, model_name.namespace)
      end
    end
  end
end
