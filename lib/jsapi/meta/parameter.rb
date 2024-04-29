# frozen_string_literal: true

require_relative 'parameter/base'
require_relative 'parameter/reference'

module Jsapi
  module Meta
    module Parameter
      class << self
        # Creates a new parameter or parameter reference.
        def new(name, keywords = {})
          if keywords[:reference] == true
            Reference.new(parameter: name)
          else
            Base.new(name, keywords)
          end
        end
      end
    end
  end
end
