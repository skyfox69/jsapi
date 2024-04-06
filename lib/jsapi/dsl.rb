# frozen_string_literal: true

require_relative 'dsl/error'
require_relative 'dsl/node'
require_relative 'dsl/definitions'
require_relative 'dsl/example'
require_relative 'dsl/schema'
require_relative 'dsl/nested_schema'
require_relative 'dsl/property'
require_relative 'dsl/parameter'
require_relative 'dsl/request_body'
require_relative 'dsl/response'
require_relative 'dsl/operation'
require_relative 'dsl/class_methods'

module Jsapi
  # Provides class methods to define top-level API components.
  # See ClassMethods for details.
  module DSL
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end
  end
end
