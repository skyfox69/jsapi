# frozen_string_literal: true

require 'test_helper'

module Jsapi
  module Meta
    module Base
      class ReferenceTest < Minitest::Test
        def test_reference_predicate
          assert_predicate(Reference.new, :reference?)
        end

        def test_resolve
          definitions = Class.new do
            def initialize(**args)
              @args = args.stringify_keys
            end

            def find_base(name)
              @args[name]
            end
          end.new(foo: model = Model.new)

          reference = Reference.new(ref: 'foo')
          assert_equal(model, reference.resolve(definitions))

          reference = Reference.new(ref: 'bar')
          error = assert_raises(ReferenceError) { reference.resolve(definitions) }
          assert_equal("reference can't be resolved: 'bar'", error.message)
        end
      end
    end
  end
end
