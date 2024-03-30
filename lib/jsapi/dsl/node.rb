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

      def method_missing(*args) # :nodoc:
        method = "#{args.first}="
        if _meta_model.respond_to?(method)
          _meta_model.public_send(method, args.second)
        else
          raise "invalid keyword: '#{args.first}'"
        end
      end

      def respond_to_missing?(param1, _param2) # :nodoc:
        _meta_model.respond_to?("#{param1}=")
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
    end
  end
end
