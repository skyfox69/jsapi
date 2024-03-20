# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define request bodies.
    class RequestBody < Node
      include Example
      include NestedSchema
    end
  end
end
