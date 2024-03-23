# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a request body.
    class RequestBody < Node
      include Example
      include NestedSchema
    end
  end
end
