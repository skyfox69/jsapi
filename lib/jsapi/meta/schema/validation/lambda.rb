# frozen_string_literal: true

module Jsapi
  module Meta
    module Schema
      module Validation
        class Lambda
          def initialize(lambda)
            @lambda = lambda
          end

          def validate(object)
            return if @lambda.nil?

            Wrapper.new(object).instance_eval(&@lambda)
          end

          class Wrapper < SimpleDelegator
            attr_reader :errors

            def initialize(object)
              super(object.value)
              @errors = object.errors
            end
          end
        end
      end
    end
  end
end
