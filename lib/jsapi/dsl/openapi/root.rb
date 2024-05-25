# frozen_string_literal: true

module Jsapi
  module DSL
    module OpenAPI
      # Used to specify details of an OpenAPI object.
      class Root < Node
        include Callbacks
      end
    end
  end
end
