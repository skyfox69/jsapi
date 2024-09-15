# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module JSON
    class ValueTest < Minitest::Test
      def test_empty_predicate
        assert(!Value.new(nil).empty?)
      end

      def test_null_predicate
        assert(!Value.new(nil).null?)
      end

      # Validation

      def test_validates_presence
        schema = Meta::Schema.new(type: 'string', existence: true)

        errors = Model::Errors.new
        assert(JSON.wrap('foo', schema).validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(!JSON.wrap('', schema).validate(errors))
        assert(errors.added?(:base, "can't be blank"))
      end

      def test_validates_allow_empty
        schema = Meta::Schema.new(type: 'string', existence: :allow_empty)

        errors = Model::Errors.new
        assert(JSON.wrap('', schema).validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(!JSON.wrap(nil, schema).validate(errors))
        assert(errors.added?(:base, "can't be blank"))
      end

      def test_validates_self_against_schema
        schema = Meta::Schema.new(type: 'string', pattern: /fo/)

        errors = Model::Errors.new
        assert(JSON.wrap(nil, schema).validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(JSON.wrap('foo', schema).validate(errors))
        assert_predicate(errors, :empty?)

        errors = Model::Errors.new
        assert(!JSON.wrap('bar', schema).validate(errors))
        assert(errors.added?(:base, 'is invalid'))
      end

      # #inspect

      def test_inspect
        assert_equal(
          '#<Jsapi::JSON::String "foo">',
          JSON.wrap('foo', Meta::Schema.new(type: 'string')).inspect
        )
      end
    end
  end
end
