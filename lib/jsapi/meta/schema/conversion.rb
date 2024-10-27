# frozen_string_literal: true

require 'active_support/concern'

module Jsapi
  module Meta
    module Schema
      module Conversion
        def self.included(base) # :nodoc:
          base.attr_accessor :conversion
        end

        def convert(object)
          return object if conversion.nil?

          if conversion.respond_to?(:call)
            conversion.call(object)
          else
            object.send(conversion)
          end
        end
      end
    end
  end
end
