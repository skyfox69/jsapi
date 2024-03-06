# frozen_string_literal: true

require_relative 'parameter/base'
require_relative 'parameter/reference'

module Jsapi
  module Meta
    module Parameter
      class << self
        def new(name, **options)
          Base.new(name, **options)
        end

        def reference(name)
          Reference.new(name)
        end
      end
    end
  end
end
