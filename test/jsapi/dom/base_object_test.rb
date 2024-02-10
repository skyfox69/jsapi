# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module DOM
    class BaseObjectTest < Minitest::Test
      def test_validates_presence
        schema = Model::Schema.new(type: 'string', existence: true)
        assert_predicate(DOM.wrap('foo', schema), :valid?)
        assert_predicate(DOM.wrap('', schema), :invalid?)
      end

      def test_validates_allow_empty
        schema = Model::Schema.new(type: 'string', existence: :allow_empty)
        assert_predicate(DOM.wrap('', schema), :valid?)
        assert_predicate(DOM.wrap(nil, schema), :invalid?)
      end

      def test_json_schema_validation
        schema = Model::Schema.new(type: 'string', min_length: 4)
        assert_predicate(DOM.wrap('foo', schema), :invalid?)
      end

      def test_skips_json_schema_validation_on_absence
        schema = Model::Schema.new(type: 'string', existence: true, min_length: 4)
        assert_predicate(DOM.wrap('', schema).errors, :one?)
      end
    end
  end
end
