# frozen_string_literal: true

module Jsapi
  module Model
    class Errors < ActiveModel::Errors
      def initialize(base = nil)
        @base = base
        @context = []
        super
      end

      def add(attribute, type = :invalid, **options)
        attribute = full_attribute(attribute)
        type = type.call(@base, options) if type.respond_to?(:call)

        errors << Error.new(@base, attribute, type, **options)
      end

      def context(attribute, &block)
        @context.push(attribute.to_sym)
        block.call if block.present?
      ensure
        @context.pop
      end

      def import(error, options = {})
        attribute = full_attribute(options[:attribute] || error.attribute)
        type = options[:type] || error.raw_type

        errors << Error.new(@base, attribute, type, **error.options)
      end

      private

      def full_attribute(attribute)
        if @context.present?
          attribute = (attribute == :base ? @context : @context + [attribute]).join('.')
        end
        attribute.to_sym
      end
    end
  end
end
