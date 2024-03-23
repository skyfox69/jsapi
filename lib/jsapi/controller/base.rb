# frozen_string_literal: true

module Jsapi
  module Controller
    # The base API controller class.
    #
    #   class FooController < Jsapi::Controller::Base
    #     api_operation do
    #       response type: 'string'
    #     end
    #
    #     def index
    #       api_operation { 'Hello world' }
    #     end
    #   end
    class Base < ActionController::API
      include DSL
      include Methods
    end
  end
end
