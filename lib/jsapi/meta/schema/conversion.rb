# frozen_string_literal: true

require 'active_support/concern'

module Jsapi
  module Meta
    module Schema
      module Conversion
        extend ActiveSupport::Concern

        included do
          # The method or +Proc+ to convert objects by.
          attr_accessor :conversion
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
