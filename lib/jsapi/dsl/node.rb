# frozen_string_literal: true

module Jsapi
  module DSL
    class Node
      def initialize(meta_model) # :nodoc:
        @_meta_model = meta_model
      end

      def call(&block) # :nodoc:
        instance_eval(&block)
      end

      def method_missing(*args, &block) # :nodoc:
        name = args.first
        method = find_method(name)
        raise "unsupported method: #{name}" unless method

        define(name) do
          value = _meta_model.public_send(method, *args[1..])
          Node.new(value).call(&block) if block
        end
      end

      def respond_to_missing?(param1, _param2) # :nodoc:
        find_method(param1).present?
      end

      private

      attr_reader :_meta_model

      def define(*args, &block)
        block.call
      rescue Error => e
        raise e.prepend_origin(args.compact.join(' '))
      rescue StandardError => e
        raise Error.new(e, args.compact.join(' ').presence)
      end

      def find_method(name)
        ["#{name}=", "add_#{name}"].find do |method|
          _meta_model.respond_to?(method)
        end
      end
    end
  end
end
