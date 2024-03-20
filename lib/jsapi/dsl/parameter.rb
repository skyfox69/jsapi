# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define (reusable) parameters.
    class Parameter < Node
      include Example
      include NestedSchema
    end
  end
end
