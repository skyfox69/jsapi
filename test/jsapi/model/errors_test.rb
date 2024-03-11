# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    class ErrorsTest < Minitest::Test
      def test_add
        errors.add(:foo)
        assert(errors.added?(:foo, :invalid))

        errors.add(:foo, :blank)
        assert(errors.added?(:foo, :blank))

        errors.add(:foo, :greater_than, count: 0)
        assert(errors.added?(:foo, :greater_than, { count: 0 }))

        errors.add(:foo, ->(_, _options) { 'bar' })
        assert(errors.added?(:foo, 'bar'))
      end

      def test_context
        # with block
        errors.context(:foo) { errors.add(:bar) }
        assert(errors.added?(:'foo.bar'))

        # without block
        errors.context(:foo)
      end

      def test_import
        error = Error.new(self, :foo)

        errors.import(error)
        assert(errors.added?(:foo, :invalid))

        errors.clear
        errors.import(error, attribute: :bar)
        assert(errors.added?(:bar, :invalid))

        errors.clear
        errors.import(error, type: :blank)
        assert(errors.added?(:foo, :blank))
      end

      private

      def errors
        @errors ||= Errors.new(self)
      end
    end
  end
end
