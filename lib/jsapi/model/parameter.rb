# frozen_string_literal: true

require_relative 'parameter/base'
require_relative 'parameter/reference'

module Jsapi
  module Model
    module Parameter
      class << self
        def new(name, **options)
          if options.key?(:$ref)
            Reference.new(options[:$ref])
          else
            Base.new(name, **options)
          end
        end
      end
    end
  end
end
