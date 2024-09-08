# frozen_string_literal: true

require_relative 'callable/symbol'
require_relative 'callable/symbol_sequence'

module Jsapi
  module Meta
    module Callable
      class << self
        def from(arg)
          raise ArgumentError, "argument can't be blank" if arg.blank?

          return arg if arg.respond_to?(:call) # e.g. a Proc

          symbols = Array.wrap(arg).flat_map do |symbol|
            next symbol if symbol.is_a?(::Symbol)

            symbol.to_s.split('.')
          end.map(&:to_sym)

          symbols.one? ? Symbol.new(symbols.first) : SymbolSequence.new(*symbols)
        end
      end
    end
  end
end
