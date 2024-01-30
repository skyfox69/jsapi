# frozen_string_literal: true

module Jsapi
  module Validators
    class LambdaValidator
      def initialize(lambda)
        @lambda = lambda
      end

      def validate(object, errors)
        return if @lambda.nil?

        Wrapper.new(object, errors).instance_eval(&@lambda)
      end

      class Wrapper < SimpleDelegator
        attr_reader :errors

        def initialize(object, errors)
          super(object)
          @errors = errors
        end
      end
    end
  end
end
