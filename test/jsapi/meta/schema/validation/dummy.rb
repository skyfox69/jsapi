# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      module Validation
        class Dummy
          include Jsapi::Validation

          attr_reader :value

          def initialize(value)
            @value = value
          end

          def empty?
            @value.empty?
          end

          def null?
            @value.nil?
          end
        end
      end
    end
  end
end
