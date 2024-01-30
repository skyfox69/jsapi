# frozen_string_literal: true

require_relative 'parameter/base'
require_relative 'parameter/reference'

module Jsapi
  module Model
    module Parameter
      class << self
        def new(name, **options)
          ref = options[:$ref]
          ref.present? ? Reference.new(ref) : Base.new(name, **options.except(:$ref))
        end
      end
    end
  end
end
