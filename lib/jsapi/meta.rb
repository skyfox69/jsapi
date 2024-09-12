# frozen_string_literal: true

require_relative 'meta/invalid_value_helper'
require_relative 'meta/invalid_value_error'
require_relative 'meta/invalid_argument_error'
require_relative 'meta/reference_error'
require_relative 'meta/callable'
require_relative 'meta/existence'
require_relative 'meta/base'
require_relative 'meta/defaults'
require_relative 'meta/openapi'
require_relative 'meta/property'
require_relative 'meta/schema'
require_relative 'meta/request_body'
require_relative 'meta/parameter'
require_relative 'meta/response'
require_relative 'meta/operation'
require_relative 'meta/rescue_handler'
require_relative 'meta/definitions'

module Jsapi
  # The meta model.
  module Meta end
end
