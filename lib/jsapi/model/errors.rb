# frozen_string_literal: true

module Jsapi
  module Model
    class Errors < ActiveModel::Errors
      def initialize(base = nil)
        @base = base
        @path = []
        super
      end

      # Overrides <tt>ActiveModel::Errors#add</tt> to wrap errors related to
      # nested models.
      def add(attribute, type = :invalid, **options)
        type = type.call(@base, options) if type.respond_to?(:call)

        errors << wrap(Error.new(@base, attribute.to_sym, type, **options))
      end

      # Overrides <tt>ActiveModel::Errors#import</tt> to wrap errors related
      # to nested models.
      def import(error, options = {})
        if (options = options.slice(:attribute, :type)).any?
          attribute = (options[:attribute] || error.attribute).to_sym
          type = options[:type] || error.raw_type
          error = Error.new(error.base, attribute, type, **error.options)
        end
        errors << wrap(error)
      end

      # Calls the block in context of +attribute+.
      def nested(attribute, &block)
        @path.push(attribute.to_sym)
        block&.call
      ensure
        @path.pop
      end

      private

      def wrap(error)
        return error if @path.empty?

        @path.reverse_each do |attribute|
          error = NestedError.new(attribute, error)
        end
        error
      end
    end
  end
end
