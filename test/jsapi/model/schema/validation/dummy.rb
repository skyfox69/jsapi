# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Model
    module Schema
      module Validation
        class Dummy
          attr_reader :errors, :value

          def initialize(value)
            @value = value
            @errors = Jsapi::Validation::Errors.new
          end
        end
      end
    end
  end
end
