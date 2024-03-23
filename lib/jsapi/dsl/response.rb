# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a response.
    class Response < Node
      include Example
      include NestedSchema
    end
  end
end
