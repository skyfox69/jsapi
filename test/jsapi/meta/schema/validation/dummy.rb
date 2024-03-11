# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      module Validation
        class Dummy
          attr_reader :errors, :value

          def initialize(value)
            @value = value
            @errors = DOM::Validation::Errors.new
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
