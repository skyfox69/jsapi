# frozen_string_literal: true

module Jsapi
  module Meta
    module Callable
      class Symbol
        attr_reader :symbol

        def initialize(symbol)
          @symbol = symbol
        end

        def inspect # :nodoc:
          "#<#{self.class.name} #{@symbol.inspect}>"
        end

        # Evaluates the symbol within the context of +object+.
        def call(object)
          if object.respond_to?(@symbol)
            object.public_send(@symbol)
          elsif object.respond_to?(:[])
            object[@symbol]
          end
        end
      end
    end
  end
end
