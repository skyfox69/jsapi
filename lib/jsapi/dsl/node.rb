# frozen_string_literal: true

module Jsapi
  module DSL
    class Node
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def call(&block)
        instance_eval(&block)
      end

      def method_missing(*args)
        wrap_error do
          if model.respond_to?(method = "#{args.first}=")
            model.public_send(method, args.second)
          else
            raise "unknown field: '#{args.first}'"
          end
        end
      end

      def respond_to_missing?(param1, _param2)
        model.respond_to?("#{param1}=")
      end

      private

      def wrap_error(*args, &block)
        block.call
      rescue Error => e
        segment = args.compact.join(' ')
        e.path.prepend(segment) if segment.present?
        raise e
      rescue StandardError => e
        raise Error.new(e, args.compact.join(' ').presence)
      end
    end
  end
end
