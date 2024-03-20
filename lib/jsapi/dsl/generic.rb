# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to create a generic node within an OpenAPI specification.
    class Generic < Node
      def method_missing(*args, &block) # :nodoc:
        if args.second.is_a?(Hash) || block
          options = args.second || {}
          child_model = _meta_model.add_child(args.first, **options)
          Generic.new(child_model).call(&block) if block
        else
          _meta_model[args.first] = args.second
        end
      end

      def respond_to_missing?(*) # :nodoc:
        true
      end
    end
  end
end
