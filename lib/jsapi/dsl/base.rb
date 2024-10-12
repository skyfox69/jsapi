# frozen_string_literal: true

module Jsapi
  module DSL
    class Base
      def initialize(meta_model, &block)
        @meta_model = meta_model

        if block
          if meta_model.reference?
            raise Error, "reference can't be specified together with a block"
          end

          instance_eval(&block)
        end
      end

      def respond_to_missing?(*args) # :nodoc:
        keyword?(args.first)
      end

      private

      def define(*args, &block)
        block.call
      rescue Error => e
        raise e.prepend_origin(args.compact.join(' '))
      rescue StandardError => e
        raise Error.new(e, args.compact.join(' ').presence)
      end

      def find_method(name)
        ["#{name}=", "add_#{name}"].find do |method|
          @meta_model.respond_to?(method)
        end
      end

      def keyword(name, *params, &block)
        method = find_method(name)
        raise "unsupported keyword: #{name}" unless method

        define(name) do
          result = @meta_model.public_send(method, *params)
          Base.new(result, &block) if block
        end
      end

      def keyword?(name)
        find_method(name).present?
      end

      alias method_missing keyword
    end
  end
end
