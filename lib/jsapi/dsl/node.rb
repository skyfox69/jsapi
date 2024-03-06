# frozen_string_literal: true

module Jsapi
  module DSL
    class Node
      attr_reader :_meta_model

      def initialize(meta_model)
        @_meta_model = meta_model
      end

      def call(&block)
        instance_eval(&block)
      end

      def method_missing(*args)
        wrap_error do
          if _meta_model.respond_to?(method = "#{args.first}=")
            _meta_model.public_send(method, args.second)
          else
            raise "unknown or invalid field: '#{args.first}'"
          end
        end
      end

      def respond_to_missing?(param1, _param2)
        _meta_model.respond_to?("#{param1}=")
      end

      private

      def wrap_error(*args, &block)
        block.call
      rescue Error => e
        raise e.prepend_origin(args.compact.join(' '))
      rescue StandardError => e
        raise Error.new(e, args.compact.join(' ').presence)
      end
    end
  end
end
