# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a parameter.
    class Parameter < Node
      include Example
      include NestedSchema
    end
  end
end
