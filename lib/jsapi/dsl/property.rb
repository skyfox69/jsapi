# frozen_string_literal: true

module Jsapi
  module DSL
    # Used to specify details of a property.
    class Property < Node
      include NestedSchema

      delegate :description, :example, to: :schema
    end
  end
end
