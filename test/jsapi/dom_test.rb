# frozen_string_literal: true

require 'test_helper'

module Jsapi
  class DOMTest < Minitest::Test
    def test_wrap_array
      json_array = DOM.wrap([], Model::Schema.new(type: 'array'))
      assert_kind_of(DOM::Array, json_array)
    end

    def test_wrap_boolean
      json_boolean = DOM.wrap(true, Model::Schema.new(type: 'boolean'))
      assert_kind_of(DOM::Boolean, json_boolean)
    end

    def test_wrap_hash
      json_object = DOM.wrap({}, Model::Schema.new(type: 'object'))
      assert_kind_of(DOM::Object, json_object)
    end

    def test_wrap_integer
      json_integer = DOM.wrap(0, Model::Schema.new(type: 'integer'))
      assert_kind_of(DOM::Integer, json_integer)
    end

    def test_wrap_nil
      json_null = DOM.wrap(nil, Model::Schema.new(type: 'object'))
      assert_kind_of(DOM::Null, json_null)
    end

    def test_wrap_number
      json_number = DOM.wrap(0, Model::Schema.new(type: 'number'))
      assert_kind_of(DOM::Number, json_number)
    end

    def test_wrap_string
      json_string = DOM.wrap('foo', Model::Schema.new(type: 'string'))
      assert_kind_of(DOM::String, json_string)
    end
  end
end
