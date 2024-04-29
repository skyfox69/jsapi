# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Schema
      class DelegatorTest < Minitest::Test
        def test_inspect
          assert_equal(
            '#<Jsapi::Meta::Schema::Delegator schema: nil, existence: nil>',
            Delegator.new(nil, nil).inspect
          )
        end
      end
    end
  end
end
