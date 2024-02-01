# frozen_string_literal: true

require_relative 'dsl/error'
require_relative 'dsl/node'
require_relative 'dsl/generic'
require_relative 'dsl/definitions'
require_relative 'dsl/schema'
require_relative 'dsl/property'
require_relative 'dsl/parameter'
require_relative 'dsl/request_body'
require_relative 'dsl/response'
require_relative 'dsl/operation'
require_relative 'dsl/class_methods'

module Jsapi
  module DSL
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
