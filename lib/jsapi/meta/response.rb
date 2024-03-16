# frozen_string_literal: true

require_relative 'response/base'
require_relative 'response/reference'

module Jsapi
  module Meta
    module Response
      class << self
        def new(**options)
          Base.new(**options)
        end

        def reference(name)
          Reference.new(name)
        end
      end
    end
  end
end
