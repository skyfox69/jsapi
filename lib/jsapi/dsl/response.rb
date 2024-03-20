# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to define (reusable) responses.
    class Response < Node
      include Example
      include NestedSchema
    end
  end
end
