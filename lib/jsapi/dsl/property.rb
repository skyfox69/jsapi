# frozen_string_literal: true

module Jsapi
  module DSL
    class Property < Node
      include NestedSchema

      delegate :description, :example, to: :schema
    end
  end
end
