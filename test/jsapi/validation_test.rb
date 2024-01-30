# frozen_string_literal: true

require 'test_helper'

module Jsapi
  class ValidationTest < Minitest::Test
    include Validation

    def test_errors
      assert_equal(%i[invalid], errors.map(&:type))
    end

    def test_valid
      assert(!valid?)
    end

    def test_invalid
      assert(invalid?)
    end

    private

    def _validate
      errors.add :invalid
    end
  end
end
