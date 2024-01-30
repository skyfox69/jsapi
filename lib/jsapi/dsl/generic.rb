# frozen_string_literal: true

module Jsapi
  module DSL
    class Generic < Node
      def method_missing(*args, &block)
        child_model = model.add_child(args.first, **(args.second || {}))
        Generic.new(child_model).call(&block) if block.present?
      end

      def respond_to_missing?(*)
        true
      end
    end
  end
end
